import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:poll_app/features/polls/data/local_poll_storage.dart';
import 'package:poll_app/features/polls/models/poll.dart';

class PollRepository {
  final FirebaseFirestore _firestore;
  final LocalPollStorage _localStorage;

  PollRepository(this._firestore, this._localStorage);

  // Stream of polls from Firestore
  Stream<List<Poll>> getPolls() {
    // Check if Firebase is initialized
    if (Firebase.apps.isEmpty) {
      debugPrint("Firebase not initialized. Returning local data only.");
      return Stream.value(_localStorage.getPolls());
    }

    try {
      return _firestore
          .collection('polls')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final polls =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  data['id'] = doc.id;
                  return Poll.fromJson(data);
                }).toList();

            _localStorage.savePolls(polls);
            return polls;
          })
          .handleError((error) {
            debugPrint("Firestore error: $error");
            return _localStorage.getPolls();
          });
    } catch (e) {
      debugPrint("Firestore exception: $e");
      return Stream.value(_localStorage.getPolls());
    }
  }

  Future<void> createPoll(Poll poll) async {
    final docRef = _firestore.collection('polls').doc();
    final newPoll = poll.copyWith(id: docRef.id);
    await docRef.set(newPoll.toJson());
    await _localStorage.markPollAsCreated(newPoll.id);
  }

  Future<void> deletePoll(String pollId) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        await _firestore.collection('polls').doc(pollId).delete();
      } catch (e) {
        debugPrint("Error deleting from Firestore: $e");
        // Proceed to delete locally anyway
      }
    }
    await _localStorage.removeCreatedPoll(pollId);
    // Also remove from local saved polls if possible, but getPolls refreshes from stream
  }

  Future<void> vote(String pollId, String optionId) async {
    final pollRef = _firestore.collection('polls').doc(pollId);

    // Get the previously voted option (null if never voted)
    final previousOptionId = _localStorage.getVotedOptionId(pollId);

    // If they're tapping the same option again, do nothing
    if (previousOptionId == optionId) return;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(pollRef);
      if (!snapshot.exists) {
        throw Exception("Poll does not exist!");
      }

      final data = snapshot.data()!;
      data['id'] = snapshot.id;
      final poll = Poll.fromJson(data);

      final updatedOptions =
          poll.options.map((option) {
            if (option.id == optionId) {
              // Increment the new choice
              return option.copyWith(voteCount: option.voteCount + 1);
            } else if (option.id == previousOptionId) {
              // Decrement the old choice (if changing vote)
              return option.copyWith(
                voteCount: (option.voteCount - 1).clamp(0, 999999),
              );
            }
            return option;
          }).toList();

      final updatedPoll = poll.copyWith(options: updatedOptions);
      transaction.update(pollRef, {
        'options': updatedPoll.options.map((e) => e.toJson()).toList(),
      });
    });

    // Store which option they voted for (not just the poll id)
    await _localStorage.markPollAsVoted(pollId, optionId: optionId);
  }
}
