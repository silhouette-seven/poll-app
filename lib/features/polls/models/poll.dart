import 'package:cloud_firestore/cloud_firestore.dart';

class PollOption {
  final String id;
  final String text;
  final int voteCount;

  PollOption({required this.id, required this.text, this.voteCount = 0});

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'voteCount': voteCount};
  }

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as String,
      text: json['text'] as String,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
    );
  }

  PollOption copyWith({String? id, String? text, int? voteCount}) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}

class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final DateTime createdAt;
  final String createdBy;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.createdBy,
  });

  int get totalVotes => options.fold(0, (sum, item) => sum + item.voteCount);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'] as String,
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => PollOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'] as String,
    );
  }

  Poll copyWith({
    String? id,
    String? question,
    List<PollOption>? options,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Poll(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
