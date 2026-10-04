import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  static const String _prefUserUidKey = 'prangan_cached_uid';

  // Safely try anonymous Firebase Auth (no provider error thrown)
  Future<User?> tryAnonymousSignIn() async {
    try {
      final cred = await _auth.signInAnonymously();
      return cred.user;
    } catch (e) {
      debugPrint('Anonymous auth note (safe fallback): $e');
      return null;
    }
  }

  // Get cached user UID from local storage
  Future<String?> getCachedUserUid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefUserUidKey);
    } catch (_) {
      return null;
    }
  }

  // Cache user UID locally
  Future<void> cacheUserUid(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefUserUidKey, uid);
    } catch (_) {}
  }

  // Clear cached UID on sign out
  Future<void> clearCachedUserUid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefUserUidKey);
    } catch (_) {}
  }

  // Demo Sign-In & Registration (No carrier SMS or disabled provider dependency)
  Future<UserModel> signInWithDemo({
    required String phoneNumber,
    required String name,
    required String flatNumber,
    required String block,
    required String role,
  }) async {
    try {
      // 1. Try Firebase anonymous session for backend integration
      final user = await tryAnonymousSignIn();
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final uid = user?.uid ?? 'user_$cleanPhone';

      // 2. Cache UID locally
      await cacheUserUid(uid);

      // 3. Store / update profile in Firestore
      final userDocRef = _firestore.collection('users').doc(uid);
      UserModel userModel;
      
      try {
        final doc = await userDocRef.get();
        if (doc.exists && doc.data() != null) {
          userModel = UserModel.fromMap(doc.data()!, uid);
          userModel = userModel.copyWith(
            name: name.isNotEmpty ? name : userModel.name,
            phone: phoneNumber.isNotEmpty ? phoneNumber : userModel.phone,
            flatNumber: flatNumber.isNotEmpty ? flatNumber : userModel.flatNumber,
            block: block.isNotEmpty ? block : userModel.block,
            role: role.isNotEmpty ? role : userModel.role,
          );
        } else {
          userModel = UserModel(
            uid: uid,
            name: name.isNotEmpty ? name : 'Resident',
            phone: phoneNumber,
            flatNumber: flatNumber,
            block: block,
            status: role.toLowerCase() == 'admin' ? 'approved' : 'pending',
            role: role.toLowerCase() == 'admin' ? 'admin' : role,
            joinedAt: DateTime.now(),
          );
        }
        await saveUserProfile(userModel);
      } catch (e) {
        debugPrint('Firestore user sync note: $e');
        userModel = UserModel(
          uid: uid,
          name: name.isNotEmpty ? name : 'Resident',
          phone: phoneNumber,
          flatNumber: flatNumber,
          block: block,
          status: role.toLowerCase() == 'admin' ? 'approved' : 'pending',
          role: role.toLowerCase() == 'admin' ? 'admin' : role,
          joinedAt: DateTime.now(),
        );
      }

      return userModel;
    } catch (e) {
      debugPrint('Error with demo sign-in: $e');
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final fallbackUid = 'user_$cleanPhone';
      await cacheUserUid(fallbackUid);
      return UserModel(
        uid: fallbackUid,
        name: name,
        phone: phoneNumber,
        flatNumber: flatNumber,
        block: block,
        status: role.toLowerCase() == 'admin' ? 'approved' : 'pending',
        role: role.toLowerCase() == 'admin' ? 'admin' : role,
        joinedAt: DateTime.now(),
      );
    }
  }

  // Continue with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      if (kIsWeb) {
        return await _auth.signInWithPopup(googleProvider);
      } else {
        return await _auth.signInWithProvider(googleProvider);
      }
    } catch (e) {
      debugPrint('Google sign-in attempt note: $e');
      rethrow;
    }
  }

  // Get User Profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Stream User Profile
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    });
  }

  // Save / Update User Profile
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
        user.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  // Real Logout: signs out, clears local cache
  Future<void> signOut() async {
    try {
      await clearCachedUserUid();
      await _auth.signOut().catchError((_) {});
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
