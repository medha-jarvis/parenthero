import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firestore_service.dart';
import 'auth_provider.dart';
import 'child_provider.dart';

// ==================================================================
// Model
// ==================================================================

/// Represents the status of a campaign.
enum CampaignStatus { active, completed, paused }

/// Extension for parsing campaign status from string.
extension CampaignStatusX on String {
  CampaignStatus toCampaignStatus() {
    switch (toLowerCase()) {
      case 'active':
        return CampaignStatus.active;
      case 'completed':
        return CampaignStatus.completed;
      case 'paused':
        return CampaignStatus.paused;
      default:
        return CampaignStatus.active;
    }
  }
}

/// Represents a day within a campaign.
class CampaignDay {
  const CampaignDay({
    this.completed = false,
    this.scriptWatched = false,
    this.practiceCompleted = false,
    this.quizCompleted = false,
    this.quizScore = 0,
    this.quizMax = 10,
    this.beatParentCompleted = false,
    this.sparkRead = false,
  });

  final bool completed;
  final bool scriptWatched;
  final bool practiceCompleted;
  final bool quizCompleted;
  final int quizScore;
  final int quizMax;
  final bool beatParentCompleted;
  final bool sparkRead;

  /// Creates from a Firestore map.
  factory CampaignDay.fromFirestore(Map<String, dynamic> data) {
    return CampaignDay(
      completed: data['completed'] as bool? ?? false,
      scriptWatched: data['scriptWatched'] as bool? ?? false,
      practiceCompleted: data['practiceCompleted'] as bool? ?? false,
      quizCompleted: data['quizCompleted'] as bool? ?? false,
      quizScore: data['quizScore'] as int? ?? 0,
      quizMax: data['quizMax'] as int? ?? 10,
      beatParentCompleted: data['beatParentCompleted'] as bool? ?? false,
      sparkRead: data['sparkRead'] as bool? ?? false,
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() => {
        'completed': completed,
        'scriptWatched': scriptWatched,
        'practiceCompleted': practiceCompleted,
        'quizCompleted': quizCompleted,
        'quizScore': quizScore,
        'quizMax': quizMax,
        'beatParentCompleted': beatParentCompleted,
        'sparkRead': sparkRead,
      };

  CampaignDay copyWith({
    bool? completed,
    bool? scriptWatched,
    bool? practiceCompleted,
    bool? quizCompleted,
    int? quizScore,
    int? quizMax,
    bool? beatParentCompleted,
    bool? sparkRead,
  }) {
    return CampaignDay(
      completed: completed ?? this.completed,
      scriptWatched: scriptWatched ?? this.scriptWatched,
      practiceCompleted: practiceCompleted ?? this.practiceCompleted,
      quizCompleted: quizCompleted ?? this.quizCompleted,
      quizScore: quizScore ?? this.quizScore,
      quizMax: quizMax ?? this.quizMax,
      beatParentCompleted: beatParentCompleted ?? this.beatParentCompleted,
      sparkRead: sparkRead ?? this.sparkRead,
    );
  }
}

/// Represents a learning campaign (child + topic + 5-day progression).
class Campaign {
  const Campaign({
    required this.id,
    required this.childId,
    required this.topicId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.days = const {},
    this.certificatesGenerated = const [],
  });

  final String id;
  final String childId;
  final String topicId;
  final CampaignStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, CampaignDay> days; // key is day number as string '1'-'5'
  final List<String> certificatesGenerated;

  /// Creates a [Campaign] from a Firestore document.
  factory Campaign.fromFirestore(String id, Map<String, dynamic> data) {
    final rawDays = data['days'] as Map<String, dynamic>? ?? {};
    final days = rawDays.map(
      (key, value) => MapEntry(
        key,
        CampaignDay.fromFirestore(value as Map<String, dynamic>),
      ),
    );

    final startedAtTimestamp = data['startedAt'] as Timestamp?;
    final completedAtTimestamp = data['completedAt'] as Timestamp?;

    return Campaign(
      id: id,
      childId: data['childId'] as String? ?? '',
      topicId: data['topicId'] as String? ?? '',
      status: (data['status'] as String? ?? 'active').toCampaignStatus(),
      startedAt: startedAtTimestamp?.toDate(),
      completedAt: completedAtTimestamp?.toDate(),
      days: days,
      certificatesGenerated:
          List<String>.from(data['certificatesGenerated'] as List? ?? []),
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() => {
        'childId': childId,
        'topicId': topicId,
        'status': status.name,
        'startedAt': startedAt != null
            ? Timestamp.fromDate(startedAt!)
            : FieldValue.serverTimestamp(),
        if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
        'days': days.map((key, value) => MapEntry(key, value.toFirestore())),
        'certificatesGenerated': certificatesGenerated,
      };

  /// Returns the current day of the campaign (1-5).
  int get currentDay {
    for (int d = 1; d <= 5; d++) {
      final day = days['$d'];
      if (day == null || !day.completed) return d;
    }
    return 5;
  }

  /// Returns the overall progress percentage (0-100).
  double get progress {
    final completedDays = days.values.where((d) => d.completed).length;
    return (completedDays / 5) * 100;
  }

  /// Returns the overall quiz score average.
  double get averageQuizScore {
    final scores = days.values
        .where((d) => d.quizMax > 0)
        .map((d) => d.quizScore / d.quizMax * 100);
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Whether all 5 days are completed.
  bool get isComplete => days.values.every((d) => d.completed);

  /// Whether this campaign is active.
  bool get isActive => status == CampaignStatus.active;

  Campaign copyWith({
    String? id,
    String? childId,
    String? topicId,
    CampaignStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, CampaignDay>? days,
    List<String>? certificatesGenerated,
  }) {
    return Campaign(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      topicId: topicId ?? this.topicId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      days: days ?? this.days,
      certificatesGenerated:
          certificatesGenerated ?? this.certificatesGenerated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Campaign &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Campaign(id: $id, child: $childId, status: $status, day: $currentDay)';
}

// ==================================================================
// Topic Model
// ==================================================================

/// Represents a learning topic.
class Topic {
  const Topic({
    required this.id,
    required this.grade,
    required this.subject,
    required this.title,
    this.description,
    this.board = 'CBSE',
    this.quarter = 1,
    this.difficulty = 1,
    this.order = 0,
    this.type = 'core',
    this.subTopics = const [],
    this.estimatedDays = 5,
    this.tags = const [],
    this.prerequisites = const [],
  });

  final String id;
  final int grade;
  final String subject;
  final String title;
  final String? description;
  final String board;
  final int quarter;
  final int difficulty;
  final int order;
  final String type;
  final List<String> subTopics;
  final int estimatedDays;
  final List<String> tags;
  final List<String> prerequisites;

  /// Creates a [Topic] from a Firestore document.
  factory Topic.fromFirestore(String id, Map<String, dynamic> data) {
    return Topic(
      id: id,
      grade: data['grade'] as int? ?? 1,
      subject: data['subject'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      board: data['board'] as String? ?? 'CBSE',
      quarter: data['quarter'] as int? ?? 1,
      difficulty: data['difficulty'] as int? ?? 1,
      order: data['order'] as int? ?? 0,
      type: data['type'] as String? ?? 'core',
      subTopics: List<String>.from(data['subTopics'] as List? ?? []),
      estimatedDays: data['estimatedDays'] as int? ?? 5,
      tags: List<String>.from(data['tags'] as List? ?? []),
      prerequisites: List<String>.from(data['prerequisites'] as List? ?? []),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Topic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Topic(id: $id, title: $title, grade: $grade)';
}

// ==================================================================
// Providers
// ==================================================================

/// Provider for the active campaign of the selected child.
final activeCampaignProvider =
    FutureProvider.family<Campaign?, String>((ref, childId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final snapshot = await firestoreService.getActiveCampaign(childId);
  if (snapshot.docs.isEmpty) return null;
  return Campaign.fromFirestore(snapshot.docs.first.id, snapshot.docs.first.data());
});

/// Stream provider for the active campaign.
final activeCampaignStreamProvider =
    StreamProvider.family<Campaign?, String>((ref, childId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamActiveCampaign(childId).map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    return Campaign.fromFirestore(snapshot.docs.first.id, snapshot.docs.first.data());
  });
});

/// Provider for all campaigns of a child.
final childCampaignsProvider =
    FutureProvider.family<List<Campaign>, String>((ref, childId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final snapshot = await firestoreService.getCampaignsByChild(childId);
  return snapshot.docs
      .map((doc) => Campaign.fromFirestore(doc.id, doc.data()))
      .toList();
});

/// Provider for topics by grade and subject.
final topicsByGradeAndSubjectProvider = FutureProvider.family<
    List<Topic>,
    ({int grade, String subject})>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final snapshot = await firestoreService.getTopicsByGradeAndSubject(
    grade: params.grade,
    subject: params.subject,
  );
  return snapshot.docs
      .map((doc) => Topic.fromFirestore(doc.id, doc.data()))
      .toList();
});

/// Provider for topics by grade.
final topicsByGradeProvider =
    FutureProvider.family<List<Topic>, int>((ref, grade) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final snapshot = await firestoreService.getTopicsByGrade(grade);
  return snapshot.docs
      .map((doc) => Topic.fromFirestore(doc.id, doc.data()))
      .toList();
});

/// Provider for a single campaign document.
final campaignByIdProvider =
    FutureProvider.family<Campaign?, String>((ref, campaignId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final snapshot = await firestoreService.getCampaign(campaignId);
  if (!snapshot.exists) return null;
  return Campaign.fromFirestore(snapshot.id, snapshot.data()!);
});

// ==================================================================
// Campaign Notifier
// ==================================================================

/// Notifier for managing campaigns.
class CampaignNotifier extends StateNotifier<AsyncValue<Campaign?>> {
  CampaignNotifier(this._firestoreService)
      : super(const AsyncValue.data(null));

  final FirestoreService _firestoreService;

  /// Loads the active campaign for a child.
  Future<void> loadActiveCampaign(String childId) async {
    state = const AsyncValue.loading();
    try {
      final query = await _firestoreService.getActiveCampaign(childId);
      if (query.docs.isEmpty) {
        state = const AsyncValue.data(null);
      } else {
        final campaign =
            Campaign.fromFirestore(query.docs.first.id, query.docs.first.data());
        state = AsyncValue.data(campaign);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Pins a new topic for a child (creates campaign).
  Future<Campaign> pinTopic({
    required String childId,
    required String topicId,
  }) async {
    try {
      // Check if campaign already exists
      final existing = await _firestoreService.getCampaignByChildAndTopic(
        childId: childId,
        topicId: topicId,
      );
      if (existing.exists) {
        final existingCampaign =
            Campaign.fromFirestore(existing.id, existing.data()!);
        if (existingCampaign.isActive) {
          state = AsyncValue.data(existingCampaign);
          return existingCampaign;
        }
      }

      // Create new campaign
      final campaignId = await _firestoreService.createCampaign(
        childId: childId,
        topicId: topicId,
      );

      // Update child's current campaign
      await _firestoreService.updateChild(childId, {
        'currentCampaignId': campaignId,
      });

      final snapshot = await _firestoreService.getCampaign(campaignId);
      final campaign =
          Campaign.fromFirestore(snapshot.id, snapshot.data()!);
      state = AsyncValue.data(campaign);
      return campaign;
    } catch (error) {
      rethrow;
    }
  }

  /// Marks a day's activity as completed.
  Future<void> completeDayActivity({
    required String campaignId,
    required int day,
    required String activity,
    int? quizScore,
    int? quizMax,
  }) async {
    try {
      await _firestoreService.completeDayActivity(
        campaignId: campaignId,
        day: day,
        activity: activity,
        quizScore: quizScore,
        quizMax: quizMax,
      );

      // Reload the campaign
      final snapshot = await _firestoreService.getCampaign(campaignId);
      if (snapshot.exists) {
        state = AsyncValue.data(
          Campaign.fromFirestore(snapshot.id, snapshot.data()!),
        );
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Marks the entire campaign as completed.
  Future<void> completeCampaign(String campaignId) async {
    try {
      await _firestoreService.completeCampaign(campaignId);

      // Reload
      final snapshot = await _firestoreService.getCampaign(campaignId);
      if (snapshot.exists) {
        state = AsyncValue.data(
          Campaign.fromFirestore(snapshot.id, snapshot.data()!),
        );
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Gets content for a specific day and type.
  Future<Map<String, dynamic>?> getContent({
    required String topicId,
    required int day,
    required String type,
  }) async {
    try {
      final snapshot = await _firestoreService.getContent(
        topicId: topicId,
        day: day,
        type: type,
      );
      if (!snapshot.exists) return null;
      return snapshot.data()?['data'] as Map<String, dynamic>?;
    } catch (error) {
      return null;
    }
  }

  /// Gets a random quiz question.
  Future<Map<String, dynamic>?> getRandomQuiz({
    required String topicId,
    required int day,
  }) async {
    try {
      return await _firestoreService.getRandomQuiz(
        topicId: topicId,
        day: day,
      );
    } catch (error) {
      return null;
    }
  }
}

/// Provider for CampaignNotifier.
final campaignProvider =
    StateNotifierProvider<CampaignNotifier, AsyncValue<Campaign?>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return CampaignNotifier(firestoreService);
});
