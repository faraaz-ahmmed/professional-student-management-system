
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  CollectionReference<Map<String, dynamic>> get _courses =>
      _firestore.collection('courses');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> showCourseForm({
    String? courseId,
    Map<String, dynamic>? course,
  }) async {
    final nameController =
        TextEditingController(text: course?['name']?.toString() ?? '');
    final codeController =
        TextEditingController(text: course?['code']?.toString() ?? '');
    final instructorController =
        TextEditingController(text: course?['instructor']?.toString() ?? '');
    final durationController =
        TextEditingController(text: course?['duration']?.toString() ?? '');

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(courseId == null ? 'Add Course' : 'Edit Course'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(nameController, 'Course Name'),
                  _field(codeController, 'Course Code'),
                  _field(instructorController, 'Instructor Name'),
                  _field(durationController, 'Duration'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.navy,
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setDialogState(() => isSaving = true);

                      try {
                        final code = codeController.text.trim();

                        final duplicate = await _courses
                            .where('code', isEqualTo: code)
                            .get();

                        final exists = duplicate.docs.any(
                          (doc) => doc.id != courseId,
                        );

                        if (exists) {
                          setDialogState(() => isSaving = false);

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Course code already exists'),
                            ),
                          );
                          return;
                        }

                        final data = <String, dynamic>{
                          'name': nameController.text.trim(),
                          'code': code,
                          'instructor': instructorController.text.trim(),
                          'duration': durationController.text.trim(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        };

                        if (courseId == null) {
                          data['createdAt'] = FieldValue.serverTimestamp();

                          await _courses.add(data);
                        } else {
                          await _courses.doc(courseId).update(data);
                        }

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }

                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                courseId == null
                                    ? 'Course added successfully'
                                    : 'Course updated successfully',
                              ),
                            ),
                          );
                        }

                        if (courseId == null) {
                          try {
                            await _firestore
                                .collection('notifications')
                                .add({
                              'title': 'New Course Added',
                              'message':
                                  '${nameController.text.trim()} ($code) added successfully.',
                              'type': 'course',
                              'isRead': false,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                          } catch (e) {
                            debugPrint('Notification error: $e');
                          }
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);

                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(courseId == null ? 'Add Course' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    codeController.dispose();
    instructorController.dispose();
    durationController.dispose();
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> deleteCourse(String courseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _courses.doc(courseId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Courses & Classes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCourseForm(),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.navy,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
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
                hintText: 'Search course or course code',
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
                  'All Courses',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const Spacer(),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _courses.snapshots(),
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data?.docs.length ?? 0} Courses',
                      style: const TextStyle(color: Colors.black54),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _courses.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load courses.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courses = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final code = data['code']?.toString().toLowerCase() ?? '';

                  return name.contains(searchQuery) ||
                      code.contains(searchQuery);
                }).toList();

                if (courses.isEmpty) {
                  return const Center(child: Text('No courses found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final doc = courses[index];
                    final course = doc.data();

                    final name = course['name']?.toString() ?? '';
                    final code = course['code']?.toString() ?? '';
                    final instructor =
                        course['instructor']?.toString() ?? '';
                    final duration = course['duration']?.toString() ?? '';

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE9A8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: AppTheme.navy,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.navy,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '$code • $duration',
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
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showCourseForm(
                                    courseId: doc.id,
                                    course: course,
                                  );
                                } else if (value == 'delete') {
                                  deleteCourse(doc.id);
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
