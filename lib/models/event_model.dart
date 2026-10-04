import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String category; // Festival, Meeting, Sports, Cultural, Health
  final String societyId;
  final String? imageUrl;
  final List<String> interestedUsers;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.societyId,
    this.imageUrl,
    this.interestedUsers = const [],
  });

  bool isInterested(String uid) => interestedUsers.contains(uid);

  factory EventModel.fromMap(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] ?? '6:00 PM',
      location: data['location'] ?? 'Clubhouse, Kharghar',
      category: data['category'] ?? 'Festival',
      societyId: data['societyId'] ?? '',
      imageUrl: data['imageUrl'],
      interestedUsers: List<String>.from(data['interestedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'category': category,
      'societyId': societyId,
      'imageUrl': imageUrl,
      'interestedUsers': interestedUsers,
    };
  }
}
