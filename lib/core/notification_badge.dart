
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationBadge {
  static final ValueNotifier<int> _unreadCount = ValueNotifier<int>(0);

  static StreamSubscription? _subscription;

  static ValueNotifier<int> get unreadCount {
    startListening();
    return _unreadCount;
  }

  static void startListening() {
    _subscription ??= FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen(
      (snapshot) {
        _unreadCount.value = snapshot.docs.length;
      },
      onError: (error) {
        debugPrint('Notification error: $error');
      },
    );
  }

  static Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _unreadCount.value = 0;
  }
}
