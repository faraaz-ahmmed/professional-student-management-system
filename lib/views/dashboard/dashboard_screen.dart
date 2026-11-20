
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../students/student_management_screen.dart';
import '../attendance/attendance_screen.dart';
import '../courses/courses_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Dashboard',
    'Students',
    'Attendance',
    'Courses',
    'Reports',
  ];

  final List<IconData> icons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.fact_check_outlined,
    Icons.menu_book_outlined,
    Icons.bar_chart_outlined,
  ];

  void selectPage(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedIndex == 0 ? 'PSMS Dashboard' : titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),

      drawer: Drawer(
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
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 38,
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

              for (int i = 0; i < titles.length; i++)
                ListTile(
                  leading: Icon(icons[i]),
                  title: Text(titles[i]),
                  selected: selectedIndex == i,
                  selectedColor: AppTheme.navy,
                  onTap: () {
                    selectPage(i);
                    Navigator.pop(context);
                  },
                ),

              const Spacer(),
              const Divider(),

              const ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings'),
              ),

              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildDashboard(),
          const StudentManagementScreen(),
          const AttendanceScreen(),
          const CoursesScreen(),
          _buildPlaceholder('Reports'),
        ],
      ),

      bottomNavigationBar: NavigationBar(
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
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back, Admin! 👋',
            style: TextStyle(
              fontSize: 23,
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

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.35,
            children: const [
              _StatCard(
                title: 'Total Students',
                value: '250',
                icon: Icons.people_alt_outlined,
                color: Color(0xFF2563EB),
              ),
              _StatCard(
                title: 'Teachers',
                value: '18',
                icon: Icons.person_outline,
                color: Color(0xFF16A34A),
              ),
              _StatCard(
                title: 'Courses',
                value: '12',
                icon: Icons.menu_book_outlined,
                color: Color(0xFF9333EA),
              ),
              _StatCard(
                title: 'Attendance',
                value: '92%',
                icon: Icons.fact_check_outlined,
                color: Color(0xFFEA8A08),
              ),
            ],
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

          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.person_add_alt_1,
                  title: 'Add Student',
                  onTap: () => selectPage(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.fact_check_outlined,
                  title: 'Attendance',
                  onTap: () => selectPage(2),
                ),
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

          const _StudentTile(
            name: 'Ali Ahmad',
            rollNo: 'PSMS-001',
            initials: 'AA',
          ),
          const _StudentTile(
            name: 'Ahmed Khan',
            rollNo: 'PSMS-002',
            initials: 'AK',
          ),
          const _StudentTile(
            name: 'Sara Malik',
            rollNo: 'PSMS-003',
            initials: 'SM',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        '$title Screen Coming Soon',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.navy,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 30),
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
