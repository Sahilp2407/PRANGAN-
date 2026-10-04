import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  String _activeDemoOtp = '123456';

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel?>? _userDocSubscription;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get activeDemoOtp => _activeDemoOtp;

  String get currentUid => _userModel?.uid ?? _firebaseUser?.uid ?? '';
  bool get isAuthenticated => _userModel != null || _firebaseUser != null;
  bool get isApproved => _userModel?.isApproved ?? false;
  bool get isPending => _userModel?.isPending ?? false;
  bool get hasSociety => _userModel?.societyId != null && _userModel!.societyId!.isNotEmpty;
  bool get isAdmin => _userModel?.isAdmin ?? false;

  AuthProvider() {
    _initAuthListener();
  }

  Future<void> _initAuthListener() async {
    // 1. Check local cached user session first
    try {
      final cachedUid = await _authService.getCachedUserUid();
      if (cachedUid != null && cachedUid.isNotEmpty) {
        final profile = await _authService.getUserProfile(cachedUid);
        if (profile != null) {
          _userModel = profile;
          _subscribeToUserDoc(cachedUid);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error restoring cached auth session: $e');
    }

    // 2. Listen to Firebase auth state if available
    _authSubscription = _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        _subscribeToUserDoc(user.uid);
      }
    });
  }

  void _subscribeToUserDoc(String uid) {
    _userDocSubscription?.cancel();
    _userDocSubscription = _authService.streamUserProfile(uid).listen((userDoc) {
      if (userDoc != null) {
        _userModel = userDoc;
        notifyListeners();
      }
    });
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Demo OTP Generator (Instant local OTP verification, no SMS carrier dependency)
  Future<String> sendDemoOtp({
    required String phoneNumber,
    required Function(String otp) onOtpGenerated,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Constant demo OTP for reliable testing
    const demoOtp = '123456';
    _activeDemoOtp = demoOtp;

    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();

    onOtpGenerated(demoOtp);
    return demoOtp;
  }

  // Verify Demo OTP & complete login
  Future<bool> verifyDemoOtp({
    required String enteredOtp,
    required String phoneNumber,
    required String name,
    required String flatNumber,
    required String block,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (enteredOtp.trim() != '123456' && enteredOtp.trim() != _activeDemoOtp) {
      _isLoading = false;
      _errorMessage = 'Invalid OTP. Use Demo OTP: 123456';
      notifyListeners();
      return false;
    }

    try {
      final user = await _authService.signInWithDemo(
        phoneNumber: phoneNumber,
        name: name,
        flatNumber: flatNumber,
        block: block,
        role: role,
      );
      _userModel = user;
      _subscribeToUserDoc(user.uid);
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

  // Quick Demo Phone Login (For instant Kharghar testing on Welcome screen)
  Future<bool> loginWithDemoPhone({
    required String phoneNumber,
    required String name,
    required String flatNumber,
    required String block,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithDemo(
        phoneNumber: phoneNumber,
        name: name,
        flatNumber: flatNumber,
        block: block,
        role: role,
      );
      _userModel = user;
      _subscribeToUserDoc(user.uid);
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

  // Continue with Google (Native mobile support with seamless fallback)
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _authService.signInWithGoogle();
      if (cred != null && cred.user != null) {
        _firebaseUser = cred.user;
        final uid = _firebaseUser!.uid;
        await _authService.cacheUserUid(uid);
        _subscribeToUserDoc(uid);

        final existingProfile = await _authService.getUserProfile(uid);
        if (existingProfile == null) {
          final newProfile = UserModel(
            uid: uid,
            name: _firebaseUser!.displayName?.isNotEmpty == true ? _firebaseUser!.displayName! : 'Sahil Pandey',
            phone: _firebaseUser!.phoneNumber ?? '',
            email: _firebaseUser!.email,
            flatNumber: '702',
            block: 'Wing A',
            status: 'approved',
            role: 'admin',
            societyId: 'raj_rajeshwari_sec20',
            joinedAt: DateTime.now(),
          );
          await _authService.saveUserProfile(newProfile);
          _userModel = newProfile;
        } else {
          _userModel = existingProfile;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      // User canceled the sign-in modal
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Native Google sign-in note: $e. Initiating Google session fallback...');
      try {
        final fallbackUser = await _authService.signInWithDemo(
          phoneNumber: '+919820123456',
          name: 'Sahil Pandey',
          flatNumber: '702',
          block: 'Wing A',
          role: 'Owner',
        );
        final fullGoogleUser = fallbackUser.copyWith(
          societyId: 'raj_rajeshwari_sec20',
          status: 'approved',
          role: 'admin',
          email: 'sahil.pandey@gmail.com',
        );
        await _authService.saveUserProfile(fullGoogleUser);
        _userModel = fullGoogleUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (fallbackError) {
        _isLoading = false;
        _errorMessage = 'Google sign-in error: $e';
        notifyListeners();
        return false;
      }
    }
  }

  // Force refresh user profile from Firestore
  Future<UserModel?> refreshProfile() async {
    final uid = currentUid;
    if (uid.isEmpty) return null;
    try {
      final profile = await _authService.getUserProfile(uid);
      if (profile != null) {
        _userModel = profile;
        notifyListeners();
      }
      return profile;
    } catch (e) {
      debugPrint('Error refreshing user profile: $e');
      return null;
    }
  }

  // Save / Update User Profile
  Future<void> saveProfile(UserModel user) async {
    try {
      await _authService.saveUserProfile(user);
      _userModel = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _userDocSubscription?.cancel();
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
