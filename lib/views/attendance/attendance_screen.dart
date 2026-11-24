
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  final Set<String> savingStudents = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get dateKey =>
      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> markAttendance(
    String studentId,
    String name,
    String rollNo,
    String status,
  ) async {
    setState(() => savingStudents.add(studentId));

    try {
      await _firestore.collection('attendance').doc('${dateKey}_$studentId').set({
        'studentId': studentId,
        'studentName': name,
        'rollNo': rollNo,
        'status': status,
        'dateKey': dateKey,
        'date': Timestamp.fromDate(selectedDate),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name marked $status'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save attendance: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => savingStudents.remove(studentId));
      }
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: pickDate,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navy,
                        ),
                      ),
                    ),
                    const Text(
                      'Change Date',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('students').snapshots(),
              builder: (context, studentSnapshot) {
                if (studentSnapshot.hasError) {
                  return const Center(child: Text('Unable to load students.'));
                }

                if (!studentSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = studentSnapshot.data!.docs;

                if (students.isEmpty) {
                  return const Center(child: Text('No students found.'));
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('attendance')
                      .where('dateKey', isEqualTo: dateKey)
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

                    final records = {
                      for (final doc in attendanceSnapshot.data!.docs)
                        doc.data()['studentId']?.toString() ?? '': doc.data(),
                    };

                    int count(String status) => records.values
                        .where((record) => record['status'] == status)
                        .length;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Present',
                                  count: count('Present'),
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Absent',
                                  count: count('Absent'),
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Late',
                                  count: count('Late'),
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Row(
                            children: [
                              const Text(
                                'Student Attendance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navy,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${records.length}/${students.length} Marked',
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              final data = student.data();

                              final name =
                                  data['name']?.toString() ?? 'Unknown';
                              final rollNo =
                                  data['rollNo']?.toString() ?? 'No Roll No';
                              final status =
                                  records[student.id]?['status']?.toString();
                              final isSaving =
                                  savingStudents.contains(student.id);

                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                const Color(0xFFFFE9A8),
                                            child: Text(
                                              name.isNotEmpty
                                                  ? name[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                color: AppTheme.navy,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.navy,
                                                  ),
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
                                          if (isSaving)
                                            const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          else if (status != null)
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: statusColor(status),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          _StatusButton(
                                            title: 'Present',
                                            color: Colors.green,
                                            selected: status == 'Present',
                                            onTap: isSaving
                                                ? null
                                                : () => markAttendance(
                                                      student.id,
                                                      name,
                                                      rollNo,
                                                      'Present',
                                                    ),
                                          ),
                                          const SizedBox(width: 8),
                                          _StatusButton(
                                            title: 'Absent',
                                            color: Colors.red,
                                            selected: status == 'Absent',
                                            onTap: isSaving
                                                ? null
                                                : () => markAttendance(
                                                      student.id,
                                                      name,
                                                      rollNo,
                                                      'Absent',
                                                    ),
                                          ),
                                          const SizedBox(width: 8),
                                          _StatusButton(
                                            title: 'Late',
                                            color: Colors.orange,
                                            selected: status == 'Late',
                                            onTap: isSaving
                                                ? null
                                                : () => markAttendance(
                                                      student.id,
                                                      name,
                                                      rollNo,
                                                      'Late',
                                                    ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
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

class _StatusButton extends StatelessWidget {
  final String title;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const _StatusButton({
    required this.title,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 9),
          backgroundColor: selected ? color : Colors.transparent,
          foregroundColor: selected ? Colors.white : color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
