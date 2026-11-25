
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String searchQuery = '';

  static const navy = Color(0xFF172554);
  static const gold = Color(0xFFEAB308);
  static const background = Color(0xFFFFFBEB);

  CollectionReference<Map<String, dynamic>> get _teachers =>
      _firestore.collection('teachers');

  CollectionReference<Map<String, dynamic>> get _courses =>
      _firestore.collection('courses');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showTeacherForm({
    DocumentSnapshot<Map<String, dynamic>>? teacher,
  }) async {
    final data = teacher?.data() ?? {};

    final nameController = TextEditingController(text: data['name'] ?? '');
    final emailController = TextEditingController(text: data['email'] ?? '');
    final phoneController = TextEditingController(text: data['phone'] ?? '');
    final subjectController =
        TextEditingController(text: data['subject'] ?? '');
    final qualificationController =
        TextEditingController(text: data['qualification'] ?? '');

    final formKey = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(teacher == null ? 'Add Teacher' : 'Edit Teacher'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(nameController, 'Teacher Name'),
                  _field(emailController, 'Email'),
                  _field(phoneController, 'Phone Number'),
                  _field(subjectController, 'Subject'),
                  _field(qualificationController, 'Qualification'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setDialogState(() => saving = true);

                      try {
                        final teacherData = {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'subject': subjectController.text.trim(),
                          'qualification':
                              qualificationController.text.trim(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        };

                        if (teacher == null) {
                          await _teachers.add({
                            ...teacherData,
                            'courseIds': [],
                            'courseNames': [],
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          await NotificationService().addNotification(
                            title: 'New Teacher Added',
                            message:
                                '${nameController.text.trim()} was added.',
                            type: 'teacher',
                          );
                        } else {
                          await _teachers.doc(teacher.id).update(teacherData);
                        }

                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              teacher == null
                                  ? 'Teacher added successfully'
                                  : 'Teacher updated successfully',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!dialogContext.mounted) return;
                        setDialogState(() => saving = false);
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
              child: saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(teacher == null ? 'Save' : 'Update'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    subjectController.dispose();
    qualificationController.dispose();
  }

  Future<void> _showTeacherDetails(
    DocumentSnapshot<Map<String, dynamic>> teacher,
  ) async {
    final data = teacher.data() ?? {};
    final courseNames = List<String>.from(data['courseNames'] ?? []);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['name'] ?? 'Teacher Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detail('Email', data['email']),
              _detail('Phone', data['phone']),
              _detail('Subject', data['subject']),
              _detail('Qualification', data['qualification']),
              const Divider(height: 24),
              const Text(
                'Assigned Courses',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 8),
              if (courseNames.isEmpty)
                const Text('No courses assigned yet')
              else
                ...courseNames.map(
                  (name) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.book, color: gold),
                    title: Text(name),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text('$label: ${value ?? '-'}'),
    );
  }

  Future<void> _assignCourses(
    DocumentSnapshot<Map<String, dynamic>> teacher,
  ) async {
    final teacherData = teacher.data() ?? {};
    final selectedCourses =
        List<String>.from(teacherData['courseIds'] ?? []);

    final messenger = ScaffoldMessenger.of(context);

    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Courses to ${teacherData['name'] ?? 'Teacher'}'),
          content: SizedBox(
            width: 400,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _courses.orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final courses = snapshot.data!.docs;

                if (courses.isEmpty) {
                  return const Text('No courses available. Add a course first.');
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: courses.map((course) {
                      final data = course.data();
                      final name = data['name'] ?? 'Unnamed Course';
                      final code = data['code'] ?? '';

                      return CheckboxListTile(
                        value: selectedCourses.contains(course.id),
                        activeColor: navy,
                        title: Text(name),
                        subtitle: Text(code),
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked == true) {
                              selectedCourses.add(course.id);
                            } else {
                              selectedCourses.remove(course.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, selectedCourses),
              child: const Text('Save Assignment'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    try {
      final courseNames = <String>[];

      for (final courseId in result) {
        final course = await _courses.doc(courseId).get();
        if (course.exists) {
          courseNames.add(course.data()?['name'] ?? 'Unnamed Course');
        }
      }

      await _teachers.doc(teacher.id).update({
        'courseIds': result,
        'courseNames': courseNames,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Courses assigned successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Assignment error: $e')),
      );
    }
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Future<void> _deleteTeacher(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: const Text('Are you sure you want to delete this teacher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _teachers.doc(id).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher deleted successfully')),
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
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Teachers Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showTeacherForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Teacher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search teachers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchQuery = '');
                  },
                  icon: const Icon(Icons.close),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _teachers.orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final teachers = snapshot.data!.docs.where((doc) {
                    final data = doc.data();
                    final name =
                        (data['name'] ?? '').toString().toLowerCase();
                    final subject =
                        (data['subject'] ?? '').toString().toLowerCase();

                    return name.contains(searchQuery) ||
                        subject.contains(searchQuery);
                  }).toList();

                  if (teachers.isEmpty) {
                    return const Center(child: Text('No teachers found'));
                  }

                  return ListView.builder(
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = teachers[index];
                      final data = teacher.data();
                      final courseCount =
                          (data['courseIds'] as List?)?.length ?? 0;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: gold.withValues(alpha: 0.2),
                            child: const Icon(Icons.person, color: navy),
                          ),
                          title: Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${data['subject'] ?? ''}\n'
                            '${data['email'] ?? ''}\n'
                            '$courseCount assigned course(s)',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'details') {
                                _showTeacherDetails(teacher);
                              } else if (value == 'assign') {
                                _assignCourses(teacher);
                              } else if (value == 'edit') {
                                _showTeacherForm(teacher: teacher);
                              } else if (value == 'delete') {
                                _deleteTeacher(teacher.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'details',
                                child: Text('Teacher Details'),
                              ),
                              PopupMenuItem(
                                value: 'assign',
                                child: Text('Assign Courses'),
                              ),
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
      ),
    );
  }
}
