import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/auth_service.dart';
import '../firebase/firestore_service.dart';

// ==================================================================
// Provider Definitions
// ==================================================================

/// Provider for the AuthService instance.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for the FirestoreService instance.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Provider that exposes the current auth state as [AsyncValue<User?>].
/// Automatically subscribes to Firebase auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider that exposes the current user as [AsyncValue<User?>].
/// Emits null when no user is signed in.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Provider that indicates whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Provider that holds the user's Firestore document data.
final currentUserDataProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, userId) async {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final snapshot = await firestoreService.getUser(userId);
    return snapshot.data();
  },
);

/// Auth notifier for managing authentication operations.
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._authService, this._firestoreService)
      : super(const AsyncValue.data(null)) {
    _authSubscription = _authService.authStateChanges.listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  StreamSubscription<User?>? _authSubscription;

  /// Returns the current user.
  User? get currentUser => state.valueOrNull;

  /// Returns whether a user is signed in.
  bool get isAuthenticated => currentUser != null;

  /// Signs up with email and password, then creates a Firestore user document.
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
        displayName: name,
      );

      final user = credential.user;
      if (user != null) {
        // Create user document in Firestore
        await _firestoreService.createUser(
          userId: user.uid,
          name: name,
          email: email,
          authProvider: 'email',
        );

        // Send email verification
        await _authService.sendEmailVerification();

        state = AsyncValue.data(user);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Signs in with email and password.
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'sign_in_failed',
          message: 'Sign-in returned no user.',
        );
      }

      state = AsyncValue.data(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Signs in with Google.
  Future<User> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'google_sign_in_failed',
          message: 'Google sign-in returned no user.',
        );
      }

      // Check if user document exists; if not, create one
      final userDoc = await _firestoreService.getUser(user.uid);
      if (!userDoc.exists) {
        await _firestoreService.createUser(
          userId: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          authProvider: 'google.com',
        );
      }

      state = AsyncValue.data(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Sends a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (error) {
      rethrow;
    }
  }

  /// Updates the current user's display name.
  Future<void> updateDisplayName(String name) async {
    await _authService.updateDisplayName(name);
    // Also update Firestore user doc
    final user = _authService.currentUser;
    if (user != null) {
      await _firestoreService.updateUser(user.uid, {'name': name});
    }
  }

  /// Deletes the current user's account.
  Future<void> deleteAccount() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _firestoreService.updateUser(user.uid, {
        'deletedAt': FieldValue.serverTimestamp(),
      });
      await _authService.deleteAccount();
    }
  }

  /// Reloads the current user.
  Future<void> reloadUser() async {
    await _authService.reloadUser();
    final user = _authService.currentUser;
    state = AsyncValue.data(user);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Riverpod StateNotifier provider for AuthNotifier.
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return AuthNotifier(authService, firestoreService);
});

/// Provider that exposes common auth operations without state.
final authActionsProvider = Provider<AuthActions>((ref) {
  final notifier = ref.watch(authProvider.notifier);
  return AuthActions(notifier);
});

/// Convenience class for exposing auth actions.
class AuthActions {
  AuthActions(this._notifier);

  final AuthNotifier _notifier;

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) =>
      _notifier.signUpWithEmail(name: name, email: email, password: password);

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _notifier.signInWithEmail(email: email, password: password);

  Future<User> signInWithGoogle() => _notifier.signInWithGoogle();

  Future<void> signOut() => _notifier.signOut();

  Future<void> resetPassword(String email) => _notifier.resetPassword(email);

  Future<void> updateDisplayName(String name) =>
      _notifier.updateDisplayName(name);

  Future<void> deleteAccount() => _notifier.deleteAccount();
}

/// Re-export FieldValue for use in providers.
// ignore: non_constant_identifier_names
dynamic get FieldValue => FirebaseFirestore.instance;
