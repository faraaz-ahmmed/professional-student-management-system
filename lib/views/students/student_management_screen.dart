
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/notification_service.dart';

class Student {
  final String id;
  final String name;
  final String rollNo;
  final String email;
  final String course;
  final String phone;

  Student({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.email,
    required this.course,
    required this.phone,
  });

  factory Student.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      rollNo: data['rollNo'] ?? '',
      email: data['email'] ?? '',
      course: data['course'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  final TextEditingController searchController = TextEditingController();

  CollectionReference<Map<String, dynamic>> get _students =>
      _firestore.collection('students');

  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> showStudentForm({Student? student}) async {
    final nameController = TextEditingController(text: student?.name ?? '');
    final rollController = TextEditingController(text: student?.rollNo ?? '');
    final emailController = TextEditingController(text: student?.email ?? '');
    final courseController = TextEditingController(text: student?.course ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameController, 'Full Name'),
              _field(rollController, 'Roll Number'),
              _field(emailController, 'Email Address'),
              _field(courseController, 'Course'),
              _field(phoneController, 'Phone Number'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.navy,
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final rollNo = rollController.text.trim();
              final email = emailController.text.trim();
              final course = courseController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty ||
                  rollNo.isEmpty ||
                  email.isEmpty ||
                  course.isEmpty ||
                  phone.isEmpty) {
                return;
              }

              try {
                final duplicate = await _students
                    .where('rollNo', isEqualTo: rollNo)
                    .get();

                final alreadyExists = duplicate.docs.any(
                  (doc) => doc.id != student?.id,
                );

                if (alreadyExists) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Roll number already exists'),
                    ),
                  );
                  return;
                }

                final studentData = {
                  'name': name,
                  'rollNo': rollNo,
                  'email': email,
                  'course': course,
                  'phone': phone,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (student == null) {
                  await _students.add({
                    ...studentData,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  await _notificationService.addNotification(
                    title: 'New Student Registered',
                    message: '$name has been added to the system.',
                    type: 'student',
                  );
                } else {
                  await _students.doc(student.id).update(studentData);
                }

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      student == null
                          ? 'Student added successfully'
                          : 'Student updated successfully',
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(student == null ? 'Add Student' : 'Save Changes'),
          ),
        ],
      ),
    );

    nameController.dispose();
    rollController.dispose();
    emailController.dispose();
    courseController.dispose();
    phoneController.dispose();
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> deleteStudent(Student student) async {
    try {
      await _students.doc(student.id).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showStudentForm(),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.navy,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase().trim());
              },
              decoration: InputDecoration(
                hintText: 'Search by name or roll number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'All Students',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const Spacer(),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _students.snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;

                    return Text(
                      '$count Students',
                      style: const TextStyle(color: Colors.black54),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _students.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load students'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final students = snapshot.data!.docs
                    .map(
                      (doc) => Student.fromFirestore(doc.id, doc.data()),
                    )
                    .where((student) {
                      return student.name.toLowerCase().contains(searchQuery) ||
                          student.rollNo.toLowerCase().contains(searchQuery);
                    })
                    .toList();

                if (students.isEmpty) {
                  return const Center(child: Text('No students found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFE9A8),
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppTheme.navy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '${student.rollNo}\n${student.course}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              showStudentForm(student: student);
                            } else if (value == 'delete') {
                              deleteStudent(student);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
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
