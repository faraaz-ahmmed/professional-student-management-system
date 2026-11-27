
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime selectedDate = DateTime.now();

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  String get selectedDateKey =>
      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  List<String> _studentCourseIds(Map<String, dynamic> data) {
    final ids = data['courseIds'];

    if (ids is List && ids.isNotEmpty) {
      return ids.map((e) => e.toString()).toList();
    }

    return [];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore.collection('students').snapshots(),
        builder: (context, studentSnapshot) {
          if (studentSnapshot.hasError) {
            return const Center(child: Text('Unable to load students.'));
          }

          if (!studentSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('courses').snapshots(),
            builder: (context, courseSnapshot) {
              if (courseSnapshot.hasError) {
                return const Center(child: Text('Unable to load courses.'));
              }

              if (!courseSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firestore
                    .collection('attendance')
                    .where('dateKey', isEqualTo: selectedDateKey)
                    .snapshots(),
                builder: (context, attendanceSnapshot) {
                  if (attendanceSnapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load attendance.'),
                    );
                  }

                  if (!attendanceSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final students = studentSnapshot.data!.docs;
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
                  final totalStudents = students.length;
                  final rate = marked == 0
                      ? 0.0
                      : (present + late) / marked;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns =
                          width >= 900 ? 4 : width >= 600 ? 2 : 1;

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
                                const SizedBox(height: 20),

                                // Date Filter
                                InkWell(
                                  onTap: _selectDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.calendar_month,
                                          color: AppTheme.navy,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _formatDate(selectedDate),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.navy,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: AppTheme.navy,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Summary Cards
                                GridView.count(
                                  crossAxisCount: columns,
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: width < 600 ? 2.1 : 1.5,
                                  children: [
                                    _ReportCard(
                                      title: 'Total Students',
                                      value: '$totalStudents',
                                      icon: Icons.people_outline,
                                      color: const Color(0xFF2563EB),
                                    ),
                                    _ReportCard(
                                      title: 'Total Courses',
                                      value: '${courses.length}',
                                      icon: Icons.menu_book_outlined,
                                      color: const Color(0xFF9333EA),
                                    ),
                                    _ReportCard(
                                      title: 'Present',
                                      value: '$present',
                                      icon: Icons.check_circle_outline,
                                      color: const Color(0xFF16A34A),
                                    ),
                                    _ReportCard(
                                      title: 'Absent',
                                      value: '$absent',
                                      icon: Icons.cancel_outlined,
                                      color: const Color(0xFFDC2626),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),

                                // Attendance Overview
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
                                            'Attendance Rate',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${(rate * 100).toStringAsFixed(1)}%',
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
                                        borderRadius: BorderRadius.circular(20),
                                        child: LinearProgressIndicator(
                                          value: rate,
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

                                // Course Summary
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
                                  ...courses.map((courseDoc) {
                                    final course = courseDoc.data();
                                    final courseId = courseDoc.id;
                                    final courseName =
                                        course['name']?.toString() ??
                                            'Unnamed Course';

                                    final enrolledStudents = students.where(
                                      (student) {
                                        final data = student.data();
                                        final ids = _studentCourseIds(data);

                                        if (ids.isNotEmpty) {
                                          return ids.contains(courseId);
                                        }

                                        return data['course']?.toString() ==
                                            courseName;
                                      },
                                    ).toList();

                                    final studentIds = enrolledStudents
                                        .map((student) => student.id)
                                        .toSet();

                                    final courseAttendance =
                                        attendance.where((record) {
                                      final data = record.data();
                                      final recordCourseId =
                                          data['courseId']?.toString();

                                      if (recordCourseId != null &&
                                          recordCourseId.isNotEmpty) {
                                        return recordCourseId == courseId &&
                                            studentIds.contains(
                                              data['studentId']?.toString(),
                                            );
                                      }

                                      return studentIds.contains(
                                        data['studentId']?.toString(),
                                      );
                                    }).toList();

                                    int coursePresent = 0;
                                    int courseAbsent = 0;
                                    int courseLate = 0;

                                    for (final record in courseAttendance) {
                                      final status = record
                                          .data()['status']
                                          ?.toString()
                                          .toLowerCase();

                                      if (status == 'present') {
                                        coursePresent++;
                                      } else if (status == 'absent') {
                                        courseAbsent++;
                                      } else if (status == 'late') {
                                        courseLate++;
                                      }
                                    }

                                    final courseMarked = coursePresent +
                                        courseAbsent +
                                        courseLate;

                                    final courseRate = courseMarked == 0
                                        ? 0.0
                                        : (coursePresent + courseLate) /
                                            courseMarked;

                                    return _CourseReport(
                                      name: courseName,
                                      code: course['code']?.toString() ?? '',
                                      instructor:
                                          course['instructor']?.toString() ??
                                              '',
                                      duration:
                                          course['duration']?.toString() ?? '',
                                      studentCount: enrolledStudents.length,
                                      attendanceRate: courseRate,
                                      present: coursePresent,
                                      absent: courseAbsent,
                                      late: courseLate,
                                      marked: courseMarked,
                                    );
                                  }),
                                const SizedBox(height: 24),
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

  const _Legend({required this.color, required this.label});

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
  final int studentCount;
  final double attendanceRate;
  final int present;
  final int absent;
  final int late;
  final int marked;

  const _CourseReport({
    required this.name,
    required this.code,
    required this.instructor,
    required this.duration,
    required this.studentCount,
    required this.attendanceRate,
    required this.present,
    required this.absent,
    required this.late,
    required this.marked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Code: $code',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            'Instructor: $instructor',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: $duration',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enrolled Students',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '$studentCount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Rate',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${(attendanceRate * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: attendanceRate,
              minHeight: 9,
              backgroundColor: const Color(0xFFFFE9A8),
              color: const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text('Present: $present'),
              Text('Absent: $absent'),
              Text('Late: $late'),
              Text('Marked: $marked'),
            ],
          ),
        ],
      ),
    );
  }
}
