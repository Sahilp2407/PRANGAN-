import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  String _selectedCategory = 'All';
  bool _showUpcomingOnly = true;

  String get selectedCategory => _selectedCategory;
  bool get showUpcomingOnly => _showUpcomingOnly;

  final List<String> categories = const [
    'All',
    'Festival',
    'Meeting',
    'Sports',
    'Cultural',
  ];

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setShowUpcomingOnly(bool val) {
    _showUpcomingOnly = val;
    notifyListeners();
  }

  // Stream events filtered by societyId
  Stream<List<EventModel>> streamEvents(String societyId) {
    return _eventService.getEventsStream(
      societyId,
      category: _selectedCategory,
    ).map((events) {
      final now = DateTime.now();
      if (_showUpcomingOnly) {
        return events.where((e) => e.date.isAfter(now.subtract(const Duration(hours: 12)))).toList();
      } else {
        return events.where((e) => e.date.isBefore(now)).toList();
      }
    });
  }

  // Toggle RSVP
  Future<void> toggleRSVP(String eventId, String uid, bool isCurrentlyInterested) async {
    try {
      await _eventService.toggleRSVP(eventId, uid, isCurrentlyInterested);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling RSVP: $e');
    }
  }

  // Create Event (Admin/Member)
  Future<bool> createEvent({
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
      await _eventService.createEvent(
        title: title,
        description: description,
        date: date,
        time: time,
        location: location,
        category: category,
        societyId: societyId,
        imageUrl: imageUrl,
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating event: $e');
      return false;
    }
  }
}
