
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 900 ? 4 : width >= 600 ? 2 : 1;

          return SingleChildScrollView(
            padding: EdgeInsets.all(width < 600 ? 16 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Institution Reports',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Overview of your institution performance.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: width < 600 ? 2.1 : 1.5,
                      children: const [
                        _ReportCard(
                          title: 'Total Students',
                          value: '250',
                          icon: Icons.people_outline,
                          color: Color(0xFF2563EB),
                        ),
                        _ReportCard(
                          title: 'Present Today',
                          value: '230',
                          icon: Icons.check_circle_outline,
                          color: Color(0xFF16A34A),
                        ),
                        _ReportCard(
                          title: 'Absent Today',
                          value: '20',
                          icon: Icons.cancel_outlined,
                          color: Color(0xFFDC2626),
                        ),
                        _ReportCard(
                          title: 'Attendance Rate',
                          value: '92%',
                          icon: Icons.trending_up,
                          color: Color(0xFF9333EA),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Attendance Overview',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overall Attendance',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '92%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const LinearProgressIndicator(
                              value: 0.92,
                              minHeight: 12,
                              backgroundColor: Color(0xFFFFE9A8),
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Wrap(
                            spacing: 20,
                            runSpacing: 12,
                            children: [
                              _Legend(
                                color: Color(0xFF16A34A),
                                label: 'Present: 230',
                              ),
                              _Legend(
                                color: Color(0xFFDC2626),
                                label: 'Absent: 20',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Course Summary',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 14),

                    const _CourseReport(
                      name: 'Computer Science',
                      students: '85 Students',
                      progress: 0.85,
                    ),
                    const _CourseReport(
                      name: 'Software Engineering',
                      students: '70 Students',
                      progress: 0.70,
                    ),
                    const _CourseReport(
                      name: 'Information Technology',
                      students: '95 Students',
                      progress: 0.95,
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9A8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.navy,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'These reports currently use sample data. '
                              'They will be connected to actual student, '
                              'course and attendance records later.',
                              style: TextStyle(
                                color: AppTheme.navy,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
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

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard({
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _CourseReport extends StatelessWidget {
  final String name;
  final String students;
  final double progress;

  const _CourseReport({
    required this.name,
    required this.students,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              Text(
                students,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFFFE9A8),
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
