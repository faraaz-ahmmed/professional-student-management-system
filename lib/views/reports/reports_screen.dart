
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  String get todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

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

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('students').snapshots(),
            builder: (context, studentSnapshot) {
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firestore.collection('courses').snapshots(),
                builder: (context, courseSnapshot) {
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: firestore
                        .collection('attendance')
                        .where('dateKey', isEqualTo: todayKey)
                        .snapshots(),
                    builder: (context, attendanceSnapshot) {
                      if (studentSnapshot.hasError ||
                          courseSnapshot.hasError ||
                          attendanceSnapshot.hasError) {
                        return const Center(
                          child: Text('Unable to load reports.'),
                        );
                      }

                      if (!studentSnapshot.hasData ||
                          !courseSnapshot.hasData ||
                          !attendanceSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final totalStudents =
                          studentSnapshot.data!.docs.length;
                      final courses = courseSnapshot.data!.docs;
                      final attendance = attendanceSnapshot.data!.docs;

                      int present = 0;
                      int absent = 0;
                      int late = 0;

                      for (final doc in attendance) {
                        final status =
                            doc.data()['status']?.toString().toLowerCase();

                        if (status == 'present') {
                          present++;
                        } else if (status == 'absent') {
                          absent++;
                        } else if (status == 'late') {
                          late++;
                        }
                      }

                      final marked = present + absent + late;
                      final attendanceRate =
                          marked == 0 ? 0.0 : (present + late) / marked;

                      final rateText =
                          '${(attendanceRate * 100).toStringAsFixed(1)}%';

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(width < 600 ? 16 : 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 1200),
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
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio:
                                      width < 600 ? 2.1 : 1.5,
                                  children: [
                                    _ReportCard(
                                      title: 'Total Students',
                                      value: '$totalStudents',
                                      icon: Icons.people_outline,
                                      color: const Color(0xFF2563EB),
                                    ),
                                    _ReportCard(
                                      title: 'Present Today',
                                      value: '$present',
                                      icon: Icons.check_circle_outline,
                                      color: const Color(0xFF16A34A),
                                    ),
                                    _ReportCard(
                                      title: 'Absent Today',
                                      value: '$absent',
                                      icon: Icons.cancel_outlined,
                                      color: const Color(0xFFDC2626),
                                    ),
                                    _ReportCard(
                                      title: 'Attendance Rate',
                                      value: rateText,
                                      icon: Icons.trending_up,
                                      color: const Color(0xFF9333EA),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Overall Attendance Today',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            rateText,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.navy,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        child: LinearProgressIndicator(
                                          value: attendanceRate,
                                          minHeight: 12,
                                          backgroundColor:
                                              const Color(0xFFFFE9A8),
                                          color: const Color(0xFF16A34A),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Wrap(
                                        spacing: 20,
                                        runSpacing: 12,
                                        children: [
                                          _Legend(
                                            color: const Color(0xFF16A34A),
                                            label: 'Present: $present',
                                          ),
                                          _Legend(
                                            color: const Color(0xFFDC2626),
                                            label: 'Absent: $absent',
                                          ),
                                          _Legend(
                                            color: const Color(0xFFF59E0B),
                                            label: 'Late: $late',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Marked: $marked / $totalStudents students',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 28),

                                Row(
                                  children: [
                                    const Text(
                                      'Course Summary',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.navy,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${courses.length} Courses',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                if (courses.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text('No courses available'),
                                    ),
                                  )
                                else
                                  ...courses.map((doc) {
                                    final course = doc.data();

                                    return _CourseReport(
                                      name: course['name']?.toString() ??
                                          'Unnamed Course',
                                      code:
                                          course['code']?.toString() ?? '',
                                      instructor:
                                          course['instructor']?.toString() ??
                                              '',
                                      duration:
                                          course['duration']?.toString() ??
                                              '',
                                    );
                                  }),

                                const SizedBox(height: 24),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE9A8),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppTheme.navy,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Reports are connected to your live '
                                          'Firestore student, course and '
                                          'attendance records.',
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
                  );
                },
              );
            },
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
  final String code;
  final String instructor;
  final String duration;

  const _CourseReport({
    required this.name,
    required this.code,
    required this.instructor,
    required this.duration,
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
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Code: $code',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Instructor: $instructor',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: $duration',
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
