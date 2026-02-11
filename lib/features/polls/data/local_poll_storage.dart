import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:poll_app/features/polls/models/poll.dart';

class LocalPollStorage {
  static const String boxName = 'polls_box';
  static const String votedBoxKey =
      'user_voted_polls'; // Key for the list of voted IDs

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

  Future<void> savePolls(List<Poll> polls) async {
    final Map<String, dynamic> data = {
      for (var poll in polls) poll.id: jsonEncode(poll.toJson()),
    };
    await _box.putAll(data);
  }

  List<Poll> getPolls() {
    if (_box.isEmpty) return [];

    // We filter values that look like poll JSON strings to avoid mixing with votedBoxKey
    // votedBoxKey stores a List, so it won't be a String starting with '{'
    return _box.values
        .whereType<String>()
        .where((e) => e.trim().startsWith('{'))
        .map((e) {
          try {
            final Map<String, dynamic> json = jsonDecode(e);
            return Poll.fromJson(json);
          } catch (e) {
            return null;
          }
        })
        .whereType<Poll>()
        .toList();
  }

  Set<String> getVotedPollIds() {
    final dynamic rawList = _box.get(votedBoxKey);
    if (rawList == null) return {};
    if (rawList is List) {
      return rawList.cast<String>().toSet();
    }
    return {};
  }

  // Track which option was voted for in each poll
  static const String votedOptionsKey = 'user_voted_options';

  String? getVotedOptionId(String pollId) {
    final dynamic rawMap = _box.get(votedOptionsKey);
    if (rawMap == null) return null;
    if (rawMap is Map) {
      return rawMap[pollId] as String?;
    }
    return null;
  }

  Future<void> markPollAsVoted(String pollId, {String? optionId}) async {
    // Keep backward-compatible poll ID list
    final current = getVotedPollIds();
    current.add(pollId);
    await _box.put(votedBoxKey, current.toList());

    // Also store which option was selected
    if (optionId != null) {
      final dynamic rawMap = _box.get(votedOptionsKey);
      final Map<String, String> optionsMap = {};
      if (rawMap is Map) {
        rawMap.forEach((key, value) {
          optionsMap[key.toString()] = value.toString();
        });
      }
      optionsMap[pollId] = optionId;
      await _box.put(votedOptionsKey, optionsMap);
    }
  }

  // Created Polls Tracking
  static const String createdBoxKey = 'user_created_polls';

  Set<String> getCreatedPollIds() {
    final List<String> list =
        _box.get(createdBoxKey, defaultValue: <String>[])?.cast<String>() ?? [];
    return list.toSet();
  }

  Future<void> markPollAsCreated(String pollId) async {
    final current = getCreatedPollIds();
    current.add(pollId);
    await _box.put(createdBoxKey, current.toList());
  }

  Future<void> removeCreatedPoll(String pollId) async {
    final current = getCreatedPollIds();
    current.remove(pollId);
    await _box.put(createdBoxKey, current.toList());
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
