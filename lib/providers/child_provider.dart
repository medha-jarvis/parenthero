import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firestore_service.dart';
import 'auth_provider.dart';

// ==================================================================
// Model
// ==================================================================

/// Represents a child profile.
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.grade,
    this.board = 'CBSE',
    this.avatarIndex = 0,
    this.currentCampaignId,
    this.stats = const ChildStats(),
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String parentId;
  final String name;
  final int age;
  final int grade;
  final String board;
  final int avatarIndex;
  final String? currentCampaignId;
  final ChildStats stats;
  final DateTime createdAt;

  /// Creates a [ChildProfile] from a Firestore document.
  factory ChildProfile.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final statsData = data['stats'] as Map<String, dynamic>? ?? {};
    final createdAtTimestamp = data['createdAt'] as Timestamp?;
    return ChildProfile(
      id: id,
      parentId: data['parentId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      age: data['age'] as int? ?? 0,
      grade: data['grade'] as int? ?? 1,
      board: data['board'] as String? ?? 'CBSE',
      avatarIndex: data['avatarIndex'] as int? ?? 0,
      currentCampaignId: data['currentCampaignId'] as String?,
      stats: ChildStats(
        streak: statsData['streak'] as int? ?? 0,
        totalTopics: statsData['totalTopics'] as int? ?? 0,
        totalQuizzes: statsData['totalQuizzes'] as int? ?? 0,
        accuracy: (statsData['accuracy'] as num?)?.toDouble() ?? 0.0,
      ),
      createdAt: createdAtTimestamp?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() => {
        'parentId': parentId,
        'name': name,
        'age': age,
        'grade': grade,
        'board': board,
        'avatarIndex': avatarIndex,
        'currentCampaignId': currentCampaignId,
        'stats': {
          'streak': stats.streak,
          'totalTopics': stats.totalTopics,
          'totalQuizzes': stats.totalQuizzes,
          'accuracy': stats.accuracy,
        },
      };

  /// Creates a copy with optionally updated fields.
  ChildProfile copyWith({
    String? id,
    String? parentId,
    String? name,
    int? age,
    int? grade,
    String? board,
    int? avatarIndex,
    String? currentCampaignId,
    ChildStats? stats,
    DateTime? createdAt,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      board: board ?? this.board,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      currentCampaignId: currentCampaignId ?? this.currentCampaignId,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ChildProfile(id: $id, name: $name, grade: $grade)';
}

/// Statistics for a child's learning progress.
class ChildStats {
  const ChildStats({
    this.streak = 0,
    this.totalTopics = 0,
    this.totalQuizzes = 0,
    this.accuracy = 0.0,
  });

  final int streak;
  final int totalTopics;
  final int totalQuizzes;
  final double accuracy;

  /// Creates a copy with optionally updated fields.
  ChildStats copyWith({
    int? streak,
    int? totalTopics,
    int? totalQuizzes,
    double? accuracy,
  }) {
    return ChildStats(
      streak: streak ?? this.streak,
      totalTopics: totalTopics ?? this.totalTopics,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildStats &&
          runtimeType == other.runtimeType &&
          streak == other.streak &&
          totalTopics == other.totalTopics &&
          totalQuizzes == other.totalQuizzes &&
          accuracy == other.accuracy;

  @override
  int get hashCode =>
      Object.hash(streak, totalTopics, totalQuizzes, accuracy);

  @override
  String toString() =>
      'ChildStats(streak: $streak, topics: $totalTopics, accuracy: $accuracy%)';
}

// ==================================================================
// Providers
// ==================================================================

/// Provider for the list of children for the current user.
final childrenListProvider =
    FutureProvider.family<List<ChildProfile>, String>(
  (ref, parentId) async {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final snapshot = await firestoreService.getChildrenByParent(parentId);
    return snapshot.docs.map((doc) {
      return ChildProfile.fromFirestore(doc.id, doc.data());
    }).toList();
  },
);

/// Provider that streams children in real-time for the authenticated user.
final childrenStreamProvider = StreamProvider<List<ChildProfile>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  if (currentUser == null) {
    return const Stream.empty();
  }

  return firestoreService
      .streamChildrenByParent(currentUser.uid)
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return ChildProfile.fromFirestore(doc.id, doc.data());
    }).toList();
  });
});

/// Provider for a single child by ID (streaming).
final childByIdProvider =
    StreamProvider.family<ChildProfile?, String>((ref, childId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamChild(childId).map((snapshot) {
    if (!snapshot.exists) return null;
    return ChildProfile.fromFirestore(snapshot.id, snapshot.data()!);
  });
});

/// Provider for the currently selected child (for use in campaign flow).
final selectedChildIdProvider = StateProvider<String?>((ref) => null);

/// Provider that gives the currently selected child profile.
final selectedChildProvider = Provider<ChildProfile?>((ref) {
  final childId = ref.watch(selectedChildIdProvider);
  if (childId == null) return null;
  return ref.watch(childByIdProvider(childId)).valueOrNull;
});

// ==================================================================
// Child Notifier
// ==================================================================

/// Notifier for managing child profiles.
class ChildNotifier extends StateNotifier<AsyncValue<List<ChildProfile>>> {
  ChildNotifier(this._firestoreService, this._getCurrentUserId)
      : super(const AsyncValue.data([]));

  final FirestoreService _firestoreService;
  final String Function() _getCurrentUserId;

  /// Loads all children for the current user.
  Future<void> loadChildren() async {
    state = const AsyncValue.loading();
    try {
      final userId = _getCurrentUserId();
      final snapshot = await _firestoreService.getChildrenByParent(userId);
      final children = snapshot.docs.map((doc) {
        return ChildProfile.fromFirestore(doc.id, doc.data());
      }).toList();
      state = AsyncValue.data(children);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Adds a new child profile.
  Future<String> addChild({
    required String name,
    required int age,
    required int grade,
    String board = 'CBSE',
    int avatarIndex = 0,
  }) async {
    try {
      final userId = _getCurrentUserId();
      final childId = await _firestoreService.createChild(
        parentId: userId,
        name: name,
        age: age,
        grade: grade,
        board: board,
        avatarIndex: avatarIndex,
      );

      // Reload children
      await loadChildren();
      return childId;
    } catch (error) {
      rethrow;
    }
  }

  /// Updates a child profile.
  Future<void> updateChild(
    String childId, {
    String? name,
    int? age,
    int? grade,
    String? board,
    int? avatarIndex,
    ChildStats? stats,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (age != null) updates['age'] = age;
      if (grade != null) updates['grade'] = grade;
      if (board != null) updates['board'] = board;
      if (avatarIndex != null) updates['avatarIndex'] = avatarIndex;
      if (stats != null) {
        updates['stats.streak'] = stats.streak;
        updates['stats.totalTopics'] = stats.totalTopics;
        updates['stats.totalQuizzes'] = stats.totalQuizzes;
        updates['stats.accuracy'] = stats.accuracy;
      }

      await _firestoreService.updateChild(childId, updates);
      await loadChildren();
    } catch (error) {
      rethrow;
    }
  }

  /// Deletes a child profile.
  Future<void> deleteChild(String childId) async {
    try {
      await _firestoreService.deleteChild(childId);
      await loadChildren();
    } catch (error) {
      rethrow;
    }
  }

  /// Updates a child's learning stats.
  Future<void> updateStats(
    String childId, {
    int? streakIncrement,
    int? totalTopicsIncrement,
    int? totalQuizzesIncrement,
    double? newAccuracy,
  }) async {
    try {
      await _firestoreService.updateChildStats(
        childId,
        streakIncrement: streakIncrement,
        totalTopicsIncrement: totalTopicsIncrement,
        totalQuizzesIncrement: totalQuizzesIncrement,
        newAccuracy: newAccuracy,
      );
      await loadChildren();
    } catch (error) {
      rethrow;
    }
  }
}

/// Provider for ChildNotifier.
final childProvider =
    StateNotifierProvider<ChildNotifier, AsyncValue<List<ChildProfile>>>(
  (ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final getUserId = () {
      final user = ref.watch(currentUserProvider);
      if (user == null) throw StateError('No authenticated user');
      return user.uid;
    };
    return ChildNotifier(firestoreService, getUserId);
  },
);
