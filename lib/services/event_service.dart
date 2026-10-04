import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Event
  Future<String> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String time,
    required String location,
    required String category,
    required String societyId,
    String? imageUrl,
  }) async {
    try {
      final docRef = _firestore.collection('events').doc();
      final event = EventModel(
        id: docRef.id,
        title: title,
        description: description,
        date: date,
        time: time,
        location: location,
        category: category,
        societyId: societyId,
        imageUrl: imageUrl,
        interestedUsers: [],
      );

      await docRef.set(event.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating event: $e');
      rethrow;
    }
  }

  // Stream Events strictly filtered by societyId
  Stream<List<EventModel>> getEventsStream(String societyId, {String? category}) {
    Query query = _firestore
        .collection('events')
        .where('societyId', isEqualTo: societyId);

    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      final events = snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  // Toggle RSVP / Interested
  Future<void> toggleRSVP(String eventId, String uid, bool isCurrentlyInterested) async {
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      if (isCurrentlyInterested) {
        await eventRef.update({
          'interestedUsers': FieldValue.arrayRemove([uid]),
        });
      } else {
        await eventRef.update({
          'interestedUsers': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      debugPrint('Error toggling RSVP: $e');
      rethrow;
    }
  }
}
