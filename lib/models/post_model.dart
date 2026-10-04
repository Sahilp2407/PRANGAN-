import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String authorUid;
  final String authorName;
  final String authorFlat;
  final String societyId;
  final String category; // General, Maintenance, Security, Social, Buy/Sell
  final String? imageUrl;
  final List<String> likes;
  final int commentCount;
  final DateTime timestamp;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorUid,
    required this.authorName,
    required this.authorFlat,
    required this.societyId,
    required this.category,
    this.imageUrl,
    this.likes = const [],
    this.commentCount = 0,
    required this.timestamp,
  });

  bool isLikedBy(String uid) => likes.contains(uid);

  factory PostModel.fromMap(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? 'Resident',
      authorFlat: data['authorFlat'] ?? '',
      societyId: data['societyId'] ?? '',
      category: data['category'] ?? 'General',
      imageUrl: data['imageUrl'],
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'authorUid': authorUid,
      'authorName': authorName,
      'authorFlat': authorFlat,
      'societyId': societyId,
      'category': category,
      'imageUrl': imageUrl,
      'likes': likes,
      'commentCount': commentCount,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  PostModel copyWith({
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    List<String>? likes,
    int? commentCount,
  }) {
    return PostModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorUid: authorUid,
      authorName: authorName,
      authorFlat: authorFlat,
      societyId: societyId,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      timestamp: timestamp,
    );
  }
}

class CommentModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String authorFlat;
  final String text;
  final DateTime timestamp;

  CommentModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.authorFlat,
    required this.text,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> data, String id) {
    return CommentModel(
      id: id,
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? 'Resident',
      authorFlat: data['authorFlat'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorUid': authorUid,
      'authorName': authorName,
      'authorFlat': authorFlat,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
