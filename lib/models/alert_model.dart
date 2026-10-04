import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'urgent', 'maintenance', 'notice'
  final String societyId;
  final DateTime timestamp;
  final List<String> readBy;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.societyId,
    required this.timestamp,
    this.readBy = const [],
  });

  bool isReadBy(String uid) => readBy.contains(uid);

  factory AlertModel.fromMap(Map<String, dynamic> data, String id) {
    return AlertModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'notice',
      societyId: data['societyId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'societyId': societyId,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
    };
  }
}
