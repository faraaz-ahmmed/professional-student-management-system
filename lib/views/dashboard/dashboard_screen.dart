
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../core/notification_badge.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../students/student_management_screen.dart';
import '../attendance/attendance_screen.dart';
import '../courses/courses_screen.dart';
import '../reports/reports_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final AuthService _authService = AuthService();

  final List<String> titles = [
    'Dashboard',
    'Students',
    'Attendance',
    'Courses',
    'Reports',
    'Notifications',
    'Profile',
  ];

  final List<IconData> icons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.fact_check_outlined,
    Icons.menu_book_outlined,
    Icons.bar_chart_outlined,
    Icons.notifications_none,
    Icons.person_outline,
  ];

  void selectPage(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          appBar: !isDesktop && selectedIndex == 0
              ? AppBar(
                  title: const Text(
                    'PSMS Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    _notificationButton(),
                    const SizedBox(width: 8),
                  ],
                )
              : null,
          drawer: !isDesktop && selectedIndex == 0 ? _buildDrawer() : null,
          body: isDesktop
              ? Row(
                  children: [
                    _buildSidebar(),
                    Expanded(child: _buildPages()),
                  ],
                )
              : _buildPages(),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex < 4 ? selectedIndex : 0,
                  onDestinationSelected: selectPage,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: 'Students',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.fact_check_outlined),
                      selectedIcon: Icon(Icons.fact_check),
                      label: 'Attendance',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: 'Courses',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _notificationButton() {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationBadge.unreadCount,
      builder: (context, unreadCount, child) {
        return IconButton(
          tooltip: 'Notifications',
          onPressed: () => selectPage(5),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 27),
              if (unreadCount > 0)
                Positioned(
                  right: -7,
                  top: -6,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 19,
                      minHeight: 19,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPages() {
    return IndexedStack(
      index: selectedIndex,
      children: [
        _DashboardHome(onNavigate: selectPage),
        const StudentManagementScreen(),
        const AttendanceScreen(),
        const CoursesScreen(),
        const ReportsScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: AppTheme.navy,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: AppTheme.primary,
                    size: 42,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'PSMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      selected: selectedIndex == index,
                      selectedTileColor: Colors.white.withValues(alpha: 0.12),
                      leading: Icon(
                        icons[index],
                        color: selectedIndex == index
                            ? AppTheme.primary
                            : Colors.white70,
                      ),
                      title: Text(
                        titles[index],
                        style: TextStyle(
                          color: selectedIndex == index
                              ? AppTheme.primary
                              : Colors.white,
                          fontWeight: selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () => selectPage(index),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white24),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white70,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppTheme.navy,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: AppTheme.navy,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'PSMS Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Administrator',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Icon(icons[index]),
                      title: Text(titles[index]),
                      selected: selectedIndex == index,
                      onTap: () {
                        selectPage(index);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _DashboardHome({required this.onNavigate});

  final List<Map<String, dynamic>> stats = const [
    {
      'title': 'Total Students',
      'collection': 'students',
      'icon': Icons.people_alt_outlined,
      'color': Color(0xFF2563EB),
    },
    {
      'title': 'Teachers',
      'collection': 'teachers',
      'icon': Icons.person_outline,
      'color': Color(0xFF16A34A),
    },
    {
      'title': 'Courses',
      'collection': 'courses',
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFF9333EA),
    },
    {
      'title': 'Attendance Records',
      'collection': 'attendance',
      'icon': Icons.fact_check_outlined,
      'color': Color(0xFFEA8A08),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 900;
        final columns = isDesktop ? 4 : width >= 600 ? 2 : 1;

        return SingleChildScrollView(
          padding: EdgeInsets.all(width < 600 ? 16 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back, Admin! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Here is your institution overview.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    itemCount: stats.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: isDesktop ? 1.5 : 1.7,
                    ),
                    itemBuilder: (context, index) {
                      final stat = stats[index];

                      return _StatCard(
                        title: stat['title'],
                        collection: stat['collection'],
                        icon: stat['icon'],
                        color: stat['color'],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ActionCard(
                        icon: Icons.people_outline,
                        title: 'Students',
                        onTap: () => onNavigate(1),
                      ),
                      _ActionCard(
                        icon: Icons.fact_check_outlined,
                        title: 'Attendance',
                        onTap: () => onNavigate(2),
                      ),
                      _ActionCard(
                        icon: Icons.menu_book_outlined,
                        title: 'Courses',
                        onTap: () => onNavigate(3),
                      ),
                      _ActionCard(
                        icon: Icons.bar_chart_outlined,
                        title: 'Reports',
                        onTap: () => onNavigate(4),
                      ),
                      _ActionCard(
                        icon: Icons.notifications_none,
                        title: 'Notifications',
                        onTap: () => onNavigate(5),
                      ),
                      _ActionCard(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () => onNavigate(6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Recent Students',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _RecentStudents(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String collection;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.collection,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String value = '...';

        if (snapshot.hasData) {
          value = snapshot.data!.docs.length.toString();
        } else if (snapshot.hasError) {
          value = 'Error';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 27),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navy,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentStudents extends StatelessWidget {
  const _RecentStudents();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Unable to load students.');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data!.docs;

        if (students.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No students added yet.'),
          );
        }

        return Column(
          children: students.map((student) {
            final data = student.data();
            final name = data['name']?.toString() ?? 'Unknown Student';
            final rollNo = data['rollNo']?.toString() ?? 'No Roll Number';
            final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

            return _StudentTile(
              name: name,
              rollNo: rollNo,
              initials: initials,
            );
          }).toList(),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primary, size: 29),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final String name;
  final String rollNo;
  final String initials;

  const _StudentTile({
    required this.name,
    required this.rollNo,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFE9A8),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppTheme.navy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  rollNo,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 15),
        ],
      ),
    );
  }
}
