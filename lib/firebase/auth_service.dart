import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service wrapping Firebase Auth.
///
/// Provides email/password and Google sign-in flows, user state stream,
/// and account management (password reset, profile update, deletion).
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ------------------------------------------------------------------
  // Streams
  // ------------------------------------------------------------------

  /// Stream of auth state changes. Emits the current [User] or null.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of user changes (profile updates, etc.).
  Stream<User?> get userChanges => _auth.userChanges();

  /// The currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  // ------------------------------------------------------------------
  // Email / Password
  // ------------------------------------------------------------------

  /// Creates a new user account with [email] and [password].
  /// Optionally sets the user's [displayName] after creation.
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
      // Force a reload so the displayName is reflected immediately
      await credential.user!.reload();
    }

    return credential;
  }

  /// Signs in an existing user with [email] and [password].
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ------------------------------------------------------------------
  // Google Sign-In
  // ------------------------------------------------------------------

  /// Signs in using Google OAuth.
  ///
  /// On Android/iOS use [GoogleSignIn] natively.
  /// On Web it falls back to Firebase Auth `signInWithPopup`.
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: use Firebase Auth Google provider directly
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(provider);
      }

      // Mobile: use GoogleSignIn plugin
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign_in_canceled',
          message: 'User canceled Google sign-in.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'google_sign_in_failed',
        message: 'Failed to sign in with Google: $e',
      );
    }
  }

  // ------------------------------------------------------------------
  // Session Management
  // ------------------------------------------------------------------

  /// Signs out the current user.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      if (!kIsWeb) _googleSignIn.signOut(),
    ]);
  }

  // ------------------------------------------------------------------
  // Account Management
  // ------------------------------------------------------------------

  /// Sends a password-reset email to [email].
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Updates the current user's display name.
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    await _auth.currentUser?.reload();
  }

  /// Updates the current user's email address.
  /// The user must have recently signed in.
  Future<void> updateEmail(String newEmail) async {
    await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail.trim());
  }

  /// Updates the current user's password.
  /// The user must have recently signed in.
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  /// Deletes the current user's account.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Sends an email verification link to the current user.
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Reloads the current user's profile from the server.
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // ------------------------------------------------------------------
  // Utility
  // ------------------------------------------------------------------

  /// Returns a [StreamSubscription] that calls [onData] on auth changes.
  StreamSubscription<User?> listenToAuthChanges(void Function(User? user) onData) {
    return authStateChanges.listen(onData);
  }

  /// Gets the idToken for the current user (e.g., for REST API auth).
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  /// Returns the currently signed-in user's UID, or throws if not signed in.
  String get userIdOrThrow {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    return user.uid;
  }
}
