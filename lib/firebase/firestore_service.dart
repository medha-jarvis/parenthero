import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore service for all ParentHero CRUD operations.
///
/// Provides strongly-typed methods for interacting with
/// Firestore collections: users, children, topics, campaigns,
/// content, certificates, and notifications.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ------------------------------------------------------------------
  // Collection References
  // ------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _children =>
      _firestore.collection('children');

  CollectionReference<Map<String, dynamic>> get _topics =>
      _firestore.collection('topics');

  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _firestore.collection('campaigns');

  CollectionReference<Map<String, dynamic>> get _content =>
      _firestore.collection('content');

  CollectionReference<Map<String, dynamic>> get _certificates =>
      _firestore.collection('certificates');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  // ==================================================================
  // USERS
  // ==================================================================

  /// Creates a new user document. Returns the created doc snapshot.
  Future<DocumentSnapshot<Map<String, dynamic>>> createUser({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String authProvider = 'email',
    Map<String, dynamic>? preferences,
  }) async {
    final data = {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'subscriptionTier': 'free',
      'subscriptionStatus': 'none',
      'authProvider': authProvider,
      'preferences': preferences ??
          {
            'notifications': true,
            'theme': 'light',
          },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _users.doc(userId).set(data);
    return _users.doc(userId).get();
  }

  /// Retrieves a user document by ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) {
    return _users.doc(userId).get();
  }

  /// Updates a user document. Merges with existing data.
  Future<void> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) {
    return _users.doc(userId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns a real-time stream of a user document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String userId) {
    return _users.doc(userId).snapshots();
  }

  // ==================================================================
  // CHILDREN
  // ==================================================================

  /// Creates a new child profile. Returns the created document ID.
  Future<String> createChild({
    required String parentId,
    required String name,
    required int age,
    required int grade,
    String board = 'CBSE',
    int avatarIndex = 0,
  }) async {
    final docRef = _children.doc();

    final data = {
      'parentId': parentId,
      'name': name,
      'age': age,
      'grade': grade,
      'board': board,
      'avatarIndex': avatarIndex,
      'createdAt': FieldValue.serverTimestamp(),
      'currentCampaignId': null,
      'stats': {
        'streak': 0,
        'totalTopics': 0,
        'totalQuizzes': 0,
        'accuracy': 0.0,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);
    return docRef.id;
  }

  /// Creates a child profile with a custom document ID.
  Future<void> createChildWithId({
    required String childId,
    required String parentId,
    required String name,
    required int age,
    required int grade,
    String board = 'CBSE',
    int avatarIndex = 0,
  }) async {
    final data = {
      'parentId': parentId,
      'name': name,
      'age': age,
      'grade': grade,
      'board': board,
      'avatarIndex': avatarIndex,
      'createdAt': FieldValue.serverTimestamp(),
      'currentCampaignId': null,
      'stats': {
        'streak': 0,
        'totalTopics': 0,
        'totalQuizzes': 0,
        'accuracy': 0.0,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _children.doc(childId).set(data);
  }

  /// Retrieves a child document by ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getChild(String childId) {
    return _children.doc(childId).get();
  }

  /// Lists all children for a given parent.
  Future<QuerySnapshot<Map<String, dynamic>>> getChildrenByParent(
    String parentId,
  ) {
    return _children
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  /// Streams all children for a given parent in real-time.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamChildrenByParent(
    String parentId,
  ) {
    return _children
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Streams a single child document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamChild(String childId) {
    return _children.doc(childId).snapshots();
  }

  /// Updates a child document.
  Future<void> updateChild(
    String childId,
    Map<String, dynamic> updates,
  ) {
    return _children.doc(childId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates a child's stats (streak, topics, quizzes, accuracy).
  Future<void> updateChildStats(
    String childId, {
    int? streakIncrement,
    int? totalTopicsIncrement,
    int? totalQuizzesIncrement,
    double? newAccuracy,
  }) async {
    final updates = <String, dynamic>{};
    if (streakIncrement != null) {
      updates['stats.streak'] = FieldValue.increment(streakIncrement);
    }
    if (totalTopicsIncrement != null) {
      updates['stats.totalTopics'] = FieldValue.increment(totalTopicsIncrement);
    }
    if (totalQuizzesIncrement != null) {
      updates['stats.totalQuizzes'] = FieldValue.increment(totalQuizzesIncrement);
    }
    if (newAccuracy != null) {
      updates['stats.accuracy'] = newAccuracy;
    }
    updates['updatedAt'] = FieldValue.serverTimestamp();

    await _children.doc(childId).update(updates);
  }

  /// Deletes a child document.
  Future<void> deleteChild(String childId) {
    return _children.doc(childId).delete();
  }

  // ==================================================================
  // TOPICS
  // ==================================================================

  /// Lists all topics for a given grade, sorted by order.
  Future<QuerySnapshot<Map<String, dynamic>>> getTopicsByGrade(int grade) {
    return _topics
        .where('grade', isEqualTo: grade)
        .orderBy('order')
        .get();
  }

  /// Lists topics by grade and subject.
  Future<QuerySnapshot<Map<String, dynamic>>> getTopicsByGradeAndSubject({
    required int grade,
    required String subject,
  }) {
    return _topics
        .where('grade', isEqualTo: grade)
        .where('subject', isEqualTo: subject)
        .orderBy('order')
        .get();
  }

  /// Streams topics by grade and subject in real-time.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamTopicsByGradeAndSubject({
    required int grade,
    required String subject,
  }) {
    return _topics
        .where('grade', isEqualTo: grade)
        .where('subject', isEqualTo: subject)
        .orderBy('order')
        .snapshots();
  }

  /// Retrieves a single topic by ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getTopic(String topicId) {
    return _topics.doc(topicId).get();
  }

  /// Lists all topics for a given board and grade.
  Future<QuerySnapshot<Map<String, dynamic>>> getTopicsByBoardAndGrade({
    required String board,
    required int grade,
  }) {
    return _topics
        .where('grade', isEqualTo: grade)
        .where('board', isEqualTo: board)
        .orderBy('order')
        .get();
  }

  /// Searches topics by title using a prefix filter (Firestore doesn't
  /// support full-text search natively, so we use >= and < for prefix).
  Future<QuerySnapshot<Map<String, dynamic>>> searchTopics(
    String query, {
    int? grade,
    String? subject,
  }) {
    final queryLower = query.toLowerCase();
    final queryEnd = '${queryLower}z'; // fake upper bound for prefix search

    Query<Map<String, dynamic>> q = _topics
        .where('titleLower', isGreaterThanOrEqualTo: queryLower)
        .where('titleLower', isLessThanOrEqualTo: queryEnd);

    if (grade != null) {
      q = q.where('grade', isEqualTo: grade);
    }
    if (subject != null) {
      q = q.where('subject', isEqualTo: subject);
    }

    return q.orderBy('titleLower').limit(20).get();
  }

  // ==================================================================
  // CAMPAIGNS
  // ==================================================================

  /// Creates a new campaign for a child pinning a topic.
  /// Returns the campaign document ID.
  Future<String> createCampaign({
    required String childId,
    required String topicId,
  }) async {
    final campaignId = '${childId}_$topicId';
    final now = FieldValue.serverTimestamp();

    final data = {
      'childId': childId,
      'topicId': topicId,
      'startedAt': now,
      'completedAt': null,
      'status': 'active',
      'days': {
        for (int d = 1; d <= 5; d++)
          '$d': {
            'completed': false,
            'scriptWatched': false,
            'practiceCompleted': false,
            'quizCompleted': false,
            'quizScore': 0,
            'quizMax': 10,
            'beatParentCompleted': false,
            'sparkRead': false,
          },
      },
      'certificatesGenerated': [],
      'createdAt': now,
      'updatedAt': now,
    };

    await _campaigns.doc(campaignId).set(data);
    return campaignId;
  }

  /// Retrieves a campaign by its composite ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getCampaign(
    String campaignId,
  ) {
    return _campaigns.doc(campaignId).get();
  }

  /// Retrieves a campaign by child and topic IDs.
  Future<DocumentSnapshot<Map<String, dynamic>>> getCampaignByChildAndTopic({
    required String childId,
    required String topicId,
  }) {
    return _campaigns.doc('${childId}_$topicId').get();
  }

  /// Returns the active campaign for a child (status = 'active').
  Future<QuerySnapshot<Map<String, dynamic>>> getActiveCampaign(
    String childId,
  ) {
    return _campaigns
        .where('childId', isEqualTo: childId)
        .where('status', isEqualTo: 'active')
        .orderBy('startedAt', descending: true)
        .limit(1)
        .get();
  }

  /// Streams the active campaign for a child.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveCampaign(
    String childId,
  ) {
    return _campaigns
        .where('childId', isEqualTo: childId)
        .where('status', isEqualTo: 'active')
        .orderBy('startedAt', descending: true)
        .limit(1)
        .snapshots();
  }

  /// Lists all campaigns for a child.
  Future<QuerySnapshot<Map<String, dynamic>>> getCampaignsByChild(
    String childId,
  ) {
    return _campaigns
        .where('childId', isEqualTo: childId)
        .orderBy('startedAt', descending: true)
        .get();
  }

  /// Streams all campaigns for a child.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCampaignsByChild(
    String childId,
  ) {
    return _campaigns
        .where('childId', isEqualTo: childId)
        .orderBy('startedAt', descending: true)
        .snapshots();
  }

  /// Updates a campaign document.
  Future<void> updateCampaign(
    String campaignId,
    Map<String, dynamic> updates,
  ) {
    return _campaigns.doc(campaignId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marks a specific day's activity as completed.
  Future<void> completeDayActivity({
    required String campaignId,
    required int day,
    required String activity, // 'scriptWatched', 'practiceCompleted', etc.
    int? quizScore,
    int? quizMax,
  }) async {
    final updates = <String, dynamic>{
      'days.$day.$activity': true,
      'days.$day.completed': true,
    };

    // Check if all activities for the day are done
    final campaignDoc = await _campaigns.doc(campaignId).get();
    final dayData = Map<String, dynamic>.from(
      (campaignDoc.data()?['days']?['$day'] as Map? ?? {}),
    );

    // Mark the activity
    dayData[activity] = true;

    // If quiz score provided, update it
    if (quizScore != null) {
      updates['days.$day.quizScore'] = quizScore;
    }
    if (quizMax != null) {
      updates['days.$day.quizMax'] = quizMax;
    }

    // Check if all 5 activities are done for this day
    const activities = [
      'scriptWatched',
      'practiceCompleted',
      'quizCompleted',
      'beatParentCompleted',
      'sparkRead',
    ];

    final allDone = activities.every((a) => dayData[a] == true);
    updates['days.$day.completed'] = allDone;

    await updateCampaign(campaignId, updates);
  }

  /// Marks a campaign as completed.
  Future<void> completeCampaign(String campaignId) async {
    await updateCampaign(campaignId, {
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Update child's currentCampaignId to null
    final campaign = await getCampaign(campaignId);
    final childId = campaign.data()?['childId'] as String?;
    if (childId != null) {
      await _children.doc(childId).update({
        'currentCampaignId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ==================================================================
  // CONTENT
  // ==================================================================

  /// Retrieves content for a specific topic, day, and type.
  Future<DocumentSnapshot<Map<String, dynamic>>> getContent({
    required String topicId,
    required int day,
    required String type,
  }) {
    final contentId = '${topicId}_${day}_$type';
    return _content.doc(contentId).get();
  }

  /// Retrieves all content for a specific topic and day.
  Future<QuerySnapshot<Map<String, dynamic>>> getContentByTopicAndDay({
    required String topicId,
    required int day,
  }) {
    return _content
        .where('topicId', isEqualTo: topicId)
        .where('day', isEqualTo: day)
        .get();
  }

  /// Retrieves a random quiz question from a topic's quiz content.
  Future<Map<String, dynamic>?> getRandomQuiz({
    required String topicId,
    required int day,
  }) async {
    final snapshot = await _content
        .where('topicId', isEqualTo: topicId)
        .where('day', isEqualTo: day)
        .where('type', isEqualTo: 'quiz')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final quizData = snapshot.docs.first.data()['data'] as Map<String, dynamic>?;
    if (quizData == null) return null;

    final questions = quizData['questions'] as List<dynamic>?;
    if (questions == null || questions.isEmpty) return null;

    // Return a random question
    final random = DateTime.now().millisecondsSinceEpoch;
    final index = random % questions.length;
    return questions[index] as Map<String, dynamic>;
  }

  // ==================================================================
  // CERTIFICATES
  // ==================================================================

  /// Creates a certificate record.
  Future<String> createCertificate(Map<String, dynamic> certificateData) async {
    final docRef = _certificates.doc();
    await docRef.set({
      ...certificateData,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Retrieves certificates for a child.
  Future<QuerySnapshot<Map<String, dynamic>>> getCertificatesByChild(
    String childId,
  ) {
    return _certificates
        .where('childId', isEqualTo: childId)
        .orderBy('completedAt', descending: true)
        .get();
  }

  /// Streams certificates for a child in real-time.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCertificatesByChild(
    String childId,
  ) {
    return _certificates
        .where('childId', isEqualTo: childId)
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  /// Retrieves a certificate by ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getCertificate(String certId) {
    return _certificates.doc(certId).get();
  }

  /// Updates a certificate (e.g., mark as shared).
  Future<void> updateCertificate(
    String certId,
    Map<String, dynamic> updates,
  ) {
    return _certificates.doc(certId).update(updates);
  }

  // ==================================================================
  // NOTIFICATIONS
  // =================================================================/

  /// Creates a notification record.
  Future<String> createNotification(Map<String, dynamic> notificationData) {
    return _notifications.add({
      ...notificationData,
      'createdAt': FieldValue.serverTimestamp(),
    }).then((ref) => ref.id);
  }

  /// Lists notifications for a user.
  Future<QuerySnapshot<Map<String, dynamic>>> getNotificationsByUser(
    String userId,
  ) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  /// Streams notifications for a user in real-time.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamNotificationsByUser(
    String userId,
  ) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ==================================================================
  // HELPERS
  // ==================================================================

  /// Runs a batch write operation.
  Future<void> runBatch(void Function(WriteBatch batch) operations) async {
    final batch = _firestore.batch();
    operations(batch);
    await batch.commit();
  }

  /// Runs a transaction.
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) operations,
  ) {
    return _firestore.runTransaction(operations);
  }

  /// Returns a GeoFirestore-like query for near location.
  /// Placeholder for future location-based features.
  Future<QuerySnapshot<Map<String, dynamic>>> geoQuery({
    required String collection,
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) {
    throw UnimplementedError('Geo queries not yet implemented');
  }
}
