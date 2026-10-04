import 'package:cloud_firestore/cloud_firestore.dart';

class PollOption {
  final String id;
  final String text;
  final int voteCount;

  PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
  });

  factory PollOption.fromMap(Map<String, dynamic> data) {
    return PollOption(
      id: data['id'] ?? '',
      text: data['text'] ?? '',
      voteCount: (data['voteCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'voteCount': voteCount,
    };
  }

  PollOption copyWith({
    String? id,
    String? text,
    int? voteCount,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}

class PollModel {
  final String id;
  final String question;
  final List<PollOption> options;
  final int totalVotes;
  final String societyId;
  final Map<String, String> votedUsers; // uid -> optionId
  final String postedBy;
  final DateTime endDate;
  final String status; // 'active', 'closed'

  PollModel({
    required this.id,
    required this.question,
    required this.options,
    this.totalVotes = 0,
    required this.societyId,
    this.votedUsers = const {},
    required this.postedBy,
    required this.endDate,
    this.status = 'active',
  });

  bool hasVoted(String uid) => votedUsers.containsKey(uid);
  String? userSelectedOptionId(String uid) => votedUsers[uid];
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActive => status == 'active' && !isExpired;

  double getPercentage(PollOption option) {
    if (totalVotes == 0) return 0.0;
    return (option.voteCount / totalVotes) * 100.0;
  }

  factory PollModel.fromMap(Map<String, dynamic> data, String id) {
    final rawOptions = data['options'] as List? ?? [];
    final optionsList = rawOptions.map((e) => PollOption.fromMap(Map<String, dynamic>.from(e))).toList();
    
    final rawVoted = data['votedUsers'];
    Map<String, String> votedMap = {};
    if (rawVoted is Map) {
      votedMap = rawVoted.map((key, value) => MapEntry(key.toString(), value.toString()));
    } else if (rawVoted is List) {
      // backward compatibility if stored as list of uids
      for (var u in rawVoted) {
        votedMap[u.toString()] = '';
      }
    }

    return PollModel(
      id: id,
      question: data['question'] ?? '',
      options: optionsList,
      totalVotes: (data['totalVotes'] as num?)?.toInt() ?? 0,
      societyId: data['societyId'] ?? '',
      votedUsers: votedMap,
      postedBy: data['postedBy'] ?? 'Managing Committee',
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 3)),
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options.map((e) => e.toMap()).toList(),
      'totalVotes': totalVotes,
      'societyId': societyId,
      'votedUsers': votedUsers,
      'postedBy': postedBy,
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
    };
  }
}
