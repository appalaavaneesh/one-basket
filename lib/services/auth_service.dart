import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

abstract class AuthService {
  Stream<UserModel?> get user;
  UserModel? get currentUser;
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<UserModel?> registerWithEmail(String name, String email, String password, String phoneNumber);
  Future<UserModel?> signInWithGoogle();
  Future<void> sendOtp(String phoneNumber, Function(String verificationId) codeSent);
  Future<UserModel?> verifyOtp(String verificationId, String smsCode, String phoneNumber);
  Future<void> signOut();
}

// ==========================================
// REAL FIREBASE AUTHENTICATION SERVICE
// ==========================================
class FirebaseAuthService implements AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Helper to map Firebase User to our custom UserModel
  UserModel? _userFromFirebase(firebase_auth.User? user) {
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'E-Commerce User',
      phoneNumber: user.phoneNumber ?? '',
      photoUrl: user.photoURL ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    );
  }

  @override
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  @override
  UserModel? get currentUser => _userFromFirebase(_auth.currentUser);

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _userFromFirebase(credential.user);
  }

  @override
  Future<UserModel?> registerWithEmail(String name, String email, String password, String phoneNumber) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(name);
    // Real firebase wouldn't set phone easily this way, but we map it to user profile later.
    return _userFromFirebase(credential.user);
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    // Check if running on web
    if (kIsWeb) {
      final googleProvider = firebase_auth.GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(googleProvider);
      return _userFromFirebase(credential.user);
    } else {
      try {
        await _googleSignIn.initialize(
          serverClientId: AppConstants.googleServerClientId.isEmpty 
              ? null 
              : AppConstants.googleServerClientId,
        );
        final googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) return null;
        final googleAuth = await googleUser.authentication;
        final credential = firebase_auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        final result = await _auth.signInWithCredential(credential);
        return _userFromFirebase(result.user);
      } catch (e) {
        if (e.toString().contains('clientConfigurationError') || e.toString().contains('serverClientId must be provided')) {
          throw Exception(
            'Google Sign-In Setup Needed:\n'
            '1. Go to Firebase Console -> Authentication -> Sign-in Method.\n'
            '2. Enable Google Sign-In and copy the "Web Client ID".\n'
            '3. Paste it inside "googleServerClientId" in lib/core/constants.dart.'
          );
        }
        rethrow;
      }
    }
  }

  @override
  Future<void> sendOtp(String phoneNumber, Function(String verificationId) codeSent) async {
    if (kIsWeb) {
      // Firebase Web Auth utilizes ConfirmationResult which is different.
      // We trigger a custom Web OTP verification or default.
      final confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
      codeSent(confirmationResult.verificationId);
    } else {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  @override
  Future<UserModel?> verifyOtp(String verificationId, String smsCode, String phoneNumber) async {
    final credential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    return _userFromFirebase(result.user);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}

// ==========================================
// MOCK / DEMO AUTHENTICATION SERVICE
// ==========================================
class MockAuthService implements AuthService {
  final _controller = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  
  MockAuthService() {
    _loadSession();
  }

  void _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('mock_uid');
    if (uid != null) {
      _currentUser = UserModel(
        uid: uid,
        email: prefs.getString('mock_email') ?? 'demo@example.com',
        displayName: prefs.getString('mock_name') ?? 'Demo User',
        phoneNumber: prefs.getString('mock_phone') ?? '+1234567890',
        photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        address: prefs.getString('mock_address'),
      );
      _controller.add(_currentUser);
    } else {
      _controller.add(null);
    }
  }

  void _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mock_uid', user.uid);
    await prefs.setString('mock_email', user.email);
    await prefs.setString('mock_name', user.displayName);
    await prefs.setString('mock_phone', user.phoneNumber);
    if (user.address != null) {
      await prefs.setString('mock_address', user.address!);
    }
  }

  void _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mock_uid');
    await prefs.remove('mock_email');
    await prefs.remove('mock_name');
    await prefs.remove('mock_phone');
    await prefs.remove('mock_address');
  }

  @override
  Stream<UserModel?> get user => _controller.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network latency
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    
    // Simulate successful login
    String name = email.split('@')[0];
    name = name[0].toUpperCase() + name.substring(1);
    
    _currentUser = UserModel(
      uid: 'mock_uid_${email.hashCode}',
      email: email,
      displayName: '$name (Demo)',
      phoneNumber: '+15550199',
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    );
    
    _saveSession(_currentUser!);
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<UserModel?> registerWithEmail(String name, String email, String password, String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }
    
    _currentUser = UserModel(
      uid: 'mock_uid_${email.hashCode}',
      email: email,
      displayName: name,
      phoneNumber: phoneNumber.isEmpty ? '+15550199' : phoneNumber,
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    );
    
    _saveSession(_currentUser!);
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    _currentUser = UserModel(
      uid: 'mock_uid_google_123',
      email: 'google.user@example.com',
      displayName: 'Google Demo User',
      phoneNumber: '+15550188',
      photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    );
    
    _saveSession(_currentUser!);
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> sendOtp(String phoneNumber, Function(String verificationId) codeSent) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Provide a mock verification ID
    codeSent('mock_verification_id_${phoneNumber.hashCode}');
  }

  @override
  Future<UserModel?> verifyOtp(String verificationId, String smsCode, String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (smsCode != '123456') {
      throw Exception('Invalid verification code. Use 123456 for demo.');
    }
    
    _currentUser = UserModel(
      uid: 'mock_uid_phone_${phoneNumber.hashCode}',
      email: 'phone.${phoneNumber.replaceAll('+', '')}@example.com',
      displayName: 'Phone User (Demo)',
      phoneNumber: phoneNumber,
      photoUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
    );
    
    _saveSession(_currentUser!);
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _clearSession();
    _currentUser = null;
    _controller.add(null);
  }
}
