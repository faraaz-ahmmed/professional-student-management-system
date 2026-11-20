
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppNotification {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  bool isRead;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> notifications = [
    AppNotification(
      title: 'New Student Registered',
      message: 'A new student has been added to the system.',
      time: '10 minutes ago',
      icon: Icons.person_add_alt_1,
      color: const Color(0xFF2563EB),
    ),
    AppNotification(
      title: 'Attendance Updated',
      message: 'Today attendance has been marked successfully.',
      time: '1 hour ago',
      icon: Icons.fact_check_outlined,
      color: const Color(0xFF16A34A),
    ),
    AppNotification(
      title: 'New Course Added',
      message: 'A new course has been added to your institution.',
      time: 'Yesterday',
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF9333EA),
      isRead: true,
    ),
    AppNotification(
      title: 'System Update',
      message: 'Your PSMS dashboard is ready to use.',
      time: '2 days ago',
      icon: Icons.system_update_outlined,
      color: const Color(0xFFEA8A08),
      isRead: true,
    ),
  ];

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  void markAsRead(AppNotification notification) {
    setState(() => notification.isRead = true);
  }

  void markAllAsRead() {
    setState(() {
      for (final notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  void deleteNotification(int index) {
    setState(() => notifications.removeAt(index));
  }

  void clearAll() {
    setState(() => notifications.clear());
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
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: AppTheme.navy),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
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
                                  onTap: () => markAsRead(notification),
                                  onDelete: () => deleteNotification(index),
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
        onTap: onTap,
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
