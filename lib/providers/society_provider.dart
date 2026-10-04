import 'dart:async';
import 'package:flutter/material.dart';
import '../models/society_model.dart';
import '../models/user_model.dart';
import '../services/society_service.dart';

class SocietyProvider extends ChangeNotifier {
  final SocietyService _societyService = SocietyService();

  SocietyModel? _currentSociety;
  SocietyModel? _searchedSociety;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<SocietyModel?>? _societySubscription;

  SocietyModel? get currentSociety => _currentSociety;
  SocietyModel? get searchedSociety => _searchedSociety;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearSearchedSociety() {
    _searchedSociety = null;
    notifyListeners();
  }

  void loadSociety(String societyId) {
    _societySubscription?.cancel();
    _societySubscription = _societyService.streamSociety(societyId).listen((society) {
      _currentSociety = society;
      notifyListeners();
    });
  }

  // Create Society
  Future<SocietyModel?> createSociety({
    required String name,
    required String address,
    required String sector,
    required String adminUid,
    required String adminName,
    required String adminPhone,
    required String adminFlat,
    required String adminBlock,
    String? logoUrl,
    int totalFlats = 100,
    int wingsCount = 2,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final society = await _societyService.createSociety(
        name: name,
        address: address,
        sector: sector,
        adminUid: adminUid,
        adminName: adminName,
        adminPhone: adminPhone,
        adminFlat: adminFlat,
        adminBlock: adminBlock,
        logoUrl: logoUrl,
        totalFlats: totalFlats,
        wingsCount: wingsCount,
      );
      _currentSociety = society;
      _isLoading = false;
      notifyListeners();
      return society;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Find Society by 6-character Join Code
  Future<SocietyModel?> searchSocietyByCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    _searchedSociety = null;
    notifyListeners();

    try {
      final society = await _societyService.findSocietyByJoinCode(code);
      _searchedSociety = society;
      if (society == null) {
        _errorMessage = 'No society found with code "$code". Please check with your committee.';
      }
      _isLoading = false;
      notifyListeners();
      return society;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Request to Join Society
  Future<bool> requestToJoin({
    required String societyId,
    required String uid,
    required String name,
    required String phone,
    required String flatNumber,
    required String block,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _societyService.requestToJoinSociety(
        societyId: societyId,
        uid: uid,
        name: name,
        phone: phone,
        flatNumber: flatNumber,
        block: block,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Stream member approval status (Used on Pending Approval screen)
  Stream<String> listenApprovalStatus(String societyId, String uid) {
    return _societyService.listenMemberStatus(societyId, uid);
  }

  // Stream pending requests for Admin screen
  Stream<List<UserModel>> getPendingRequestsStream(String societyId) {
    return _societyService.getPendingMembersStream(societyId);
  }

  // Admin Approve Member
  Future<bool> approveMember(String societyId, String uid) async {
    try {
      await _societyService.approveMember(societyId, uid);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Admin Reject Member
  Future<bool> rejectMember(String societyId, String uid) async {
    try {
      await _societyService.rejectMember(societyId, uid);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _societySubscription?.cancel();
    super.dispose();
  }
}
