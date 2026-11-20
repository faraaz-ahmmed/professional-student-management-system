
import 'package:flutter/foundation.dart';

class NotificationBadge {
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(2);

  static void decrease() {
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }
  }

  static void clear() {
    unreadCount.value = 0;
  }
}
