
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showTeacherForm({DocumentSnapshot? teacher}) async {
    final nameController =
        TextEditingController(text: teacher?['name'] ?? '');
    final emailController =
        TextEditingController(text: teacher?['email'] ?? '');
    final phoneController =
        TextEditingController(text: teacher?['phone'] ?? '');
    final subjectController =
        TextEditingController(text: teacher?['subject'] ?? '');
    final qualificationController =
        TextEditingController(text: teacher?['qualification'] ?? '');

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
              onPressed: saving
                  ? null
                  : () => Navigator.pop(dialogContext),
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
                        final data = {
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
                            ...data,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          await NotificationService().addNotification(
                            title: 'New Teacher Added',
                            message:
                                '${nameController.text.trim()} was added.',
                            type: 'teacher',
                          );
                        } else {
                          await _teachers.doc(teacher.id).update(data);
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                    return const Center(child: CircularProgressIndicator());
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
                            '${data['subject'] ?? ''}\n${data['email'] ?? ''}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showTeacherForm(teacher: teacher);
                              } else if (value == 'delete') {
                                _deleteTeacher(teacher.id);
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
      ),
    );
  }
}
