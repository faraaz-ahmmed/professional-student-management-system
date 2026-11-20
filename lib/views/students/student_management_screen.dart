
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class Student {
  String name;
  String rollNo;
  String email;
  String course;
  String phone;

  Student({
    required this.name,
    required this.rollNo,
    required this.email,
    required this.course,
    required this.phone,
  });
}

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final List<Student> students = [
    Student(
      name: 'Ali Ahmad',
      rollNo: 'PSMS-001',
      email: 'ali@gmail.com',
      course: 'Computer Science',
      phone: '03001234567',
    ),
    Student(
      name: 'Ahmed Khan',
      rollNo: 'PSMS-002',
      email: 'ahmed@gmail.com',
      course: 'Software Engineering',
      phone: '03001234568',
    ),
    Student(
      name: 'Sara Malik',
      rollNo: 'PSMS-003',
      email: 'sara@gmail.com',
      course: 'Information Technology',
      phone: '03001234569',
    ),
  ];

  final searchController = TextEditingController();

  List<Student> get filteredStudents {
    final query = searchController.text.toLowerCase();

    return students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.rollNo.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showStudentForm({Student? student}) {
    final nameController = TextEditingController(text: student?.name ?? '');
    final rollController = TextEditingController(text: student?.rollNo ?? '');
    final emailController = TextEditingController(text: student?.email ?? '');
    final courseController = TextEditingController(text: student?.course ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');

    showDialog(
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
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  rollController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty ||
                  courseController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                return;
              }

              final duplicate = students.any((item) =>
                  item.rollNo.toLowerCase() ==
                      rollController.text.trim().toLowerCase() &&
                  item != student);

              if (duplicate) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Roll number already exists')),
                );
                return;
              }

              setState(() {
                if (student == null) {
                  students.add(
                    Student(
                      name: nameController.text.trim(),
                      rollNo: rollController.text.trim(),
                      email: emailController.text.trim(),
                      course: courseController.text.trim(),
                      phone: phoneController.text.trim(),
                    ),
                  );
                } else {
                  student.name = nameController.text.trim();
                  student.rollNo = rollController.text.trim();
                  student.email = emailController.text.trim();
                  student.course = courseController.text.trim();
                  student.phone = phoneController.text.trim();
                }
              });

              Navigator.pop(dialogContext);
            },
            child: Text(student == null ? 'Add Student' : 'Save Changes'),
          ),
        ],
      ),
    );
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

  void deleteStudent(Student student) {
    setState(() => students.remove(student));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredStudents;

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
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by name or roll number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
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
                Text(
                  '${students.length} Students',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No students found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final student = filtered[index];

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
                            itemBuilder: (_) => const [
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
                  ),
          ),
        ],
      ),
    );
  }
}
