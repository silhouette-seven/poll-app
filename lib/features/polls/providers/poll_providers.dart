import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poll_app/features/polls/data/local_poll_storage.dart';
import 'package:poll_app/features/polls/data/poll_repository.dart';
import 'package:poll_app/features/polls/models/poll.dart';

// Dependencies
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final localPollStorageProvider = Provider<LocalPollStorage>((ref) {
  return LocalPollStorage();
});

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(localPollStorageProvider);
  return PollRepository(firestore, storage);
});

// State
final pollsStreamProvider = StreamProvider<List<Poll>>((ref) {
  final repository = ref.watch(pollRepositoryProvider);
  final storage = ref.watch(localPollStorageProvider);

  // Return local data stream if offline, or Firestore stream
  return repository.getPolls().handleError((e) {
    // If stream errors, fallback to local storage
    return storage.getPolls();
  });
});

// Created Polls Provider
final createdPollsProvider = FutureProvider<List<Poll>>((ref) async {
  final storage = ref.watch(localPollStorageProvider);
  final createdIds = storage.getCreatedPollIds();
  final allLocalPolls = storage.getPolls();
  return allLocalPolls.where((p) => createdIds.contains(p.id)).toList();
});

// Connectivity Provider
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.any((r) => r != ConnectivityResult.none),
  );
});
