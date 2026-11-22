
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/notification_badge.dart';
import '../../services/notification_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.isRead,
  });

  factory AppNotification.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final type = data['type'] ?? 'system';

    IconData icon = Icons.notifications_outlined;
    Color color = const Color(0xFFEA8A08);

    if (type == 'student') {
      icon = Icons.person_add_alt_1;
      color = const Color(0xFF2563EB);
    } else if (type == 'course') {
      icon = Icons.menu_book_outlined;
      color = const Color(0xFF9333EA);
    } else if (type == 'attendance') {
      icon = Icons.fact_check_outlined;
      color = const Color(0xFF16A34A);
    }

    final timestamp = data['createdAt'] as Timestamp?;
    String time = 'Just now';

    if (timestamp != null) {
      final difference = DateTime.now().difference(timestamp.toDate());

      if (difference.inMinutes < 1) {
        time = 'Just now';
      } else if (difference.inHours < 1) {
        time = '${difference.inMinutes} minutes ago';
      } else if (difference.inDays < 1) {
        time = '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        time = 'Yesterday';
      } else {
        time = '${difference.inDays} days ago';
      }
    }

    return AppNotification(
      id: id,
      title: data['title'] ?? 'Notification',
      message: data['message'] ?? '',
      time: time,
      icon: icon,
      color: color,
      isRead: data['isRead'] ?? false,
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  Future<void> markAsRead(String id) async {
    await _notificationService.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  Future<void> deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
  }

  Future<void> clearAll() async {
    await _notificationService.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: NotificationBadge.unreadCount,
            builder: (context, count, child) {
              if (count == 0) return const SizedBox.shrink();

              return TextButton(
                onPressed: markAllAsRead,
                child: const Text(
                  'Mark all read',
                  style: TextStyle(color: AppTheme.navy),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load notifications'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          final notifications = docs
              .map(
                (doc) => AppNotification.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList();

          final unreadCount =
              notifications.where((notification) => !notification.isRead).length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: EdgeInsets.all(isWide ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.navy,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.notifications_active_outlined,
                                color: AppTheme.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your Notifications',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$unreadCount unread notifications',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (notifications.isNotEmpty)
                                IconButton(
                                  onPressed: clearAll,
                                  tooltip: 'Clear all',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: notifications.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.notifications_off_outlined,
                                        size: 55,
                                        color: Colors.black26,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No notifications',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: notifications.length,
                                  itemBuilder: (context, index) {
                                    final notification = notifications[index];

                                    return _NotificationTile(
                                      notification: notification,
                                      onTap: () => markAsRead(notification.id),
                                      onDelete: () =>
                                          deleteNotification(notification.id),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : const Color(0xFFFFF1C2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? Colors.transparent
              : AppTheme.primary.withValues(alpha: 0.45),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        onTap: notification.isRead ? null : onTap,
        leading: CircleAvatar(
          backgroundColor: notification.color.withValues(alpha: 0.12),
          child: Icon(notification.icon, color: notification.color),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            color: AppTheme.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              const SizedBox(height: 7),
              Text(
                notification.time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'read') {
              onTap();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'read',
                child: Text('Mark as read'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
