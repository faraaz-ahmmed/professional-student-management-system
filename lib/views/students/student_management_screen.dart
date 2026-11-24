
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Student(
      id: doc.id,
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

class _StudentManagementScreenState
    extends State<StudentManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  final TextEditingController _searchController = TextEditingController();

  CollectionReference<Map<String, dynamic>> get _students =>
      _firestore.collection('students');

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showStudentDialog({Student? student}) async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: student?.name ?? '');
    final rollController = TextEditingController(
      text: student == null
          ? ''
          : student.rollNo.replaceFirst(
              RegExp(r'^PSMS-', caseSensitive: false),
              '',
            ),
    );
    final emailController = TextEditingController(text: student?.email ?? '');
    final courseController =
        TextEditingController(text: student?.course ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');

    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveStudent() async {
              if (!formKey.currentState!.validate()) return;

              setDialogState(() => isSaving = true);

              try {
                final name = nameController.text.trim();
                final rollDigits = rollController.text.trim();
                final rollNo = 'PSMS-$rollDigits';

                final duplicate = await _students
                    .where('rollNo', isEqualTo: rollNo)
                    .get();

                if (!dialogContext.mounted) return;

                final alreadyExists = duplicate.docs.any(
                  (doc) => doc.id != student?.id,
                );

                if (alreadyExists) {
                  setDialogState(() => isSaving = false);

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('This roll number already exists.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final studentData = {
                  'name': name,
                  'rollNo': rollNo,
                  'email': emailController.text.trim(),
                  'course': courseController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (student == null) {
                  await _students.add({
                    ...studentData,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  await _students.doc(student.id).update(studentData);
                }

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                if (!mounted) return;

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      student == null
                          ? 'Student added successfully.'
                          : 'Student updated successfully.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );

                if (student == null) {
                  try {
                    await _notificationService.addNotification(
                      title: 'New Student Added',
                      message: '$name ($rollNo) has been added.',
                      type: 'student',
                    );
                  } catch (e) {
                    debugPrint('Notification error: $e');
                  }
                }
              } catch (e) {
                if (!dialogContext.mounted) return;

                setDialogState(() => isSaving = false);

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              title: Text(
                student == null ? 'Add New Student' : 'Edit Student',
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildField(
                          nameController,
                          'Student Name',
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          rollController,
                          'Roll Number',
                          Icons.badge_outlined,
                          prefixText: 'PSMS-',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Roll number is required';
                            }

                            if (!RegExp(r'^\d{3,}$').hasMatch(value.trim())) {
                              return 'Enter at least 3 digits';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          emailController,
                          'Email Address',
                          Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          courseController,
                          'Course',
                          Icons.menu_book_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          phoneController,
                          'Phone Number',
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : saveStudent,
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(student == null ? 'Add Student' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    rollController.dispose();
    emailController.dispose();
    courseController.dispose();
    phoneController.dispose();
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _deleteStudent(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _students.doc(student.id).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting student: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _students.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Something went wrong: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data!.docs
            .map((doc) => Student.fromFirestore(doc))
            .where((student) {
          final query = _searchQuery.toLowerCase();

          return student.name.toLowerCase().contains(query) ||
              student.rollNo.toLowerCase().contains(query) ||
              student.course.toLowerCase().contains(query);
        }).toList();

        final totalStudents = snapshot.data!.docs.length;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Student Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showStudentDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 35,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Students'),
                          Text(
                            '$totalStudents',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim());
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, roll number or course...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: students.isEmpty
                    ? const Center(
                        child: Text('No students found.'),
                      )
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  student.name.isNotEmpty
                                      ? student.name[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${student.rollNo} • ${student.course}\n'
                                '${student.email}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showStudentDialog(student: student);
                                  } else if (value == 'delete') {
                                    _deleteStudent(student);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
