import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';

class AlertProvider extends ChangeNotifier {
  final AlertService _alertService = AlertService();

  String _selectedType = 'All';

  String get selectedType => _selectedType;

  final List<String> alertTypes = const [
    'All',
    'Urgent',
    'Maintenance',
    'Notice',
  ];

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  // Stream alerts filtered by societyId and selectedType
  Stream<List<AlertModel>> streamAlerts(String societyId) {
    return _alertService.getAlertsStream(societyId).map((alerts) {
      if (_selectedType == 'All') return alerts;
      return alerts.where((a) => a.type.toLowerCase() == _selectedType.toLowerCase()).toList();
    });
  }

  // Stream unread count for Dashboard bell badge
  Stream<int> streamUnreadCount(String societyId, String uid) {
    return _alertService.getAlertsStream(societyId).map((alerts) {
      return alerts.where((a) => !a.isReadBy(uid)).length;
    });
  }

  // Mark single alert read
  Future<void> markRead(String alertId, String uid) async {
    try {
      await _alertService.markAlertRead(alertId, uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking alert read: $e');
    }
  }

  // Mark all alerts read
  Future<void> markAllRead(String societyId, String uid) async {
    try {
      await _alertService.markAllAlertsRead(societyId, uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all alerts read: $e');
    }
  }

  // Create Alert
  Future<bool> createAlert({
    required String title,
    required String description,
    required String type,
    required String societyId,
  }) async {
    try {
      await _alertService.createAlert(
        title: title,
        description: description,
        type: type,
        societyId: societyId,
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating alert: $e');
      return false;
    }
  }
}
