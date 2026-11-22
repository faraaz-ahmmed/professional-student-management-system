
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    await _notifications.add({
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotifications() {
    return _notifications.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUnreadNotifications() {
    return _notifications
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  Future<void> markAsRead(String id) async {
    await _notifications.doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final snapshot = await getUnreadNotifications().first;
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String id) async {
    await _notifications.doc(id).delete();
  }

  Future<void> clearAll() async {
    final snapshot = await getNotifications().first;
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
