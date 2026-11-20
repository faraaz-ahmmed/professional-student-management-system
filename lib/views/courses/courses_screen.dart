
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class Course {
  String name;
  String code;
  String instructor;
  String duration;

  Course({
    required this.name,
    required this.code,
    required this.instructor,
    required this.duration,
  });
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final List<Course> courses = [
    Course(
      name: 'Computer Science',
      code: 'CS-101',
      instructor: 'Mr. Ahmad',
      duration: '4 Years',
    ),
    Course(
      name: 'Software Engineering',
      code: 'SE-201',
      instructor: 'Mr. Ali',
      duration: '4 Years',
    ),
    Course(
      name: 'Information Technology',
      code: 'IT-301',
      instructor: 'Ms. Sara',
      duration: '4 Years',
    ),
  ];

  final searchController = TextEditingController();

  List<Course> get filteredCourses {
    final query = searchController.text.toLowerCase();

    return courses.where((course) {
      return course.name.toLowerCase().contains(query) ||
          course.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showCourseForm({Course? course}) {
    final nameController = TextEditingController(text: course?.name ?? '');
    final codeController = TextEditingController(text: course?.code ?? '');
    final instructorController =
        TextEditingController(text: course?.instructor ?? '');
    final durationController =
        TextEditingController(text: course?.duration ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(course == null ? 'Add Course' : 'Edit Course'),
        content: SingleChildScrollView(
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
                  codeController.text.trim().isEmpty ||
                  instructorController.text.trim().isEmpty ||
                  durationController.text.trim().isEmpty) {
                return;
              }

              final code = codeController.text.trim();

              final duplicate = courses.any(
                (item) =>
                    item.code.toLowerCase() == code.toLowerCase() &&
                    item != course,
              );

              if (duplicate) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course code already exists'),
                  ),
                );
                return;
              }

              setState(() {
                if (course == null) {
                  courses.add(
                    Course(
                      name: nameController.text.trim(),
                      code: code,
                      instructor: instructorController.text.trim(),
                      duration: durationController.text.trim(),
                    ),
                  );
                } else {
                  course.name = nameController.text.trim();
                  course.code = code;
                  course.instructor = instructorController.text.trim();
                  course.duration = durationController.text.trim();
                }
              });

              Navigator.pop(dialogContext);
            },
            child: Text(course == null ? 'Add Course' : 'Save Changes'),
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

  void deleteCourse(Course course) {
    setState(() => courses.remove(course));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredCourses;

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
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search course or course code',
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
                  'All Courses',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const Spacer(),
                Text(
                  '${courses.length} Courses',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No courses found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final course = filtered[index];

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
                                      course.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.navy,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${course.code} • ${course.duration}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Instructor: ${course.instructor}',
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
                                    showCourseForm(course: course);
                                  } else if (value == 'delete') {
                                    deleteCourse(course);
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
