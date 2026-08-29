import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  // ==============================================================
  // FIREBASE AUTH
  // ==============================================================

  final FirebaseAuth _auth;

  final UserService _userService;

  AuthService({
    FirebaseAuth? auth,
    UserService? userService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userService = userService ?? UserService();

  // ==============================================================
  // CURRENT FIREBASE USER
  // ==============================================================

  User? get currentUser => _auth.currentUser;

  // ==============================================================
  // CURRENT USER ID
  // ==============================================================

  String? get currentUserId => _auth.currentUser?.uid;

  // ==============================================================
  // CHECK LOGIN STATUS
  // ==============================================================

  bool get isLoggedIn => _auth.currentUser != null;

  // ==============================================================
  // AUTH STATE STREAM
  // ==============================================================

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // ==============================================================
  // SEND OTP
  // ==============================================================
  //
  // IMPORTANT:
  //
  // Phone number must include country code.
  //
  // Example:
  //
  // +919876543210
  //
  // ==============================================================

  Future<void> sendOtp({
    required String phoneNumber,

    required void Function(
      String verificationId,
      int? resendToken,
    ) onCodeSent,

    required void Function(
      PhoneAuthCredential credential,
    ) verificationCompleted,

    required void Function(
      FirebaseAuthException exception,
    ) verificationFailed,

    required void Function(
      String verificationId,
    ) codeAutoRetrievalTimeout,

    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),

      timeout: const Duration(
        seconds: 60,
      ),

      forceResendingToken:
          forceResendingToken,

      // ==========================================================
      // AUTO VERIFICATION
      // ==========================================================

      verificationCompleted:
          verificationCompleted,

      // ==========================================================
      // VERIFICATION FAILED
      // ==========================================================

      verificationFailed:
          verificationFailed,

      // ==========================================================
      // OTP SENT SUCCESSFULLY
      // ==========================================================

      codeSent: (
        String verificationId,
        int? resendToken,
      ) {
        onCodeSent(
          verificationId,
          resendToken,
        );
      },

      // ==========================================================
      // AUTO RETRIEVAL TIMEOUT
      // ==========================================================

      codeAutoRetrievalTimeout:
          codeAutoRetrievalTimeout,
    );
  }

  // ==============================================================
  // VERIFY OTP
  // ==============================================================
  //
  // Creates Firebase phone credential
  // and signs the user in.
  //
  // ==============================================================

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final cleanOtp = smsCode.trim();

    if (cleanOtp.length != 6) {
      throw FirebaseAuthException(
        code: 'invalid-verification-code',
        message:
            'Please enter a valid 6-digit verification code.',
      );
    }

    final credential =
        PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: cleanOtp,
    );

    return await _auth.signInWithCredential(
      credential,
    );
  }

  // ==============================================================
  // AUTO SIGN-IN
  // ==============================================================
  //
  // Used when Firebase automatically verifies
  // the user's phone number.
  //
  // ==============================================================

  Future<UserCredential> signInWithCredential({
    required PhoneAuthCredential credential,
  }) async {
    return await _auth.signInWithCredential(
      credential,
    );
  }

  // ==============================================================
  // CREATE USER PROFILE IF NEEDED
  // ==============================================================
  //
  // Called AFTER successful authentication.
  //
  // Existing user:
  // → Do not overwrite profile.
  //
  // New user:
  // → Create users/{uid} document.
  //
  // ==============================================================

  Future<bool> createUserProfileIfNeeded({
    String? name,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    // ============================================================
    // CHECK EXISTING FIRESTORE USER
    // ============================================================

    final existingUser =
        await _userService.getUser(
      user.uid,
    );

    // ============================================================
    // EXISTING USER
    // ============================================================

    if (existingUser != null) {
      return false;
    }

    // ============================================================
    // NEW USER
    // ============================================================

    final newUser = UserModel(
      uid: user.uid,

      name: name?.trim() ?? '',

      email: user.email ?? '',

      phone: user.phoneNumber ?? '',

      profileImageUrl:
          user.photoURL,

      isActive: true,

      isProfileCompleted: false,
    );

    // ============================================================
    // CREATE FIRESTORE USER
    // ============================================================

    await _userService.createUser(
      user: newUser,
    );

    return true;
  }

  // ==============================================================
  // GET CURRENT FIRESTORE PROFILE
  // ==============================================================

  Future<UserModel?> getCurrentUserProfile() async {
    final uid = currentUserId;

    if (uid == null) {
      return null;
    }

    return await _userService.getUser(
      uid,
    );
  }

  // ==============================================================
  // CHECK WHETHER PROFILE EXISTS
  // ==============================================================

  Future<bool> hasUserProfile() async {
    final uid = currentUserId;

    if (uid == null) {
      return false;
    }

    final user =
        await _userService.getUser(uid);

    return user != null;
  }

  // ==============================================================
  // SIGN OUT
  // ==============================================================

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==============================================================
  // DELETE AUTH ACCOUNT
  // ==============================================================

  Future<void> deleteAuthAccount() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await user.delete();
  }

  // ==============================================================
  // RELOAD CURRENT USER
  // ==============================================================

  Future<void> reloadCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await user.reload();
  }
}