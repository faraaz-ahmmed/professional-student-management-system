
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  UserModel? user;
  bool isLoading = true;
  bool isSaving = false;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final currentUser = _authService.currentUser;

      if (currentUser == null) return;

      final profile = await _userService.getUser(currentUser.uid);

      if (!mounted) return;

      setState(() {
        user = profile;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('Unable to load profile: $e');
    }
  }

  Future<void> _editProfile() async {
    if (user == null) return;

    final nameController = TextEditingController(text: user!.name);
    final phoneController = TextEditingController(text: user!.phone);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(text: user!.email),
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    helperText: 'Email cannot be changed here',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();

      if (name.isEmpty) {
        _showMessage('Name cannot be empty.');
      } else {
        await _saveProfile(name, phone);
      }
    }

    nameController.dispose();
    phoneController.dispose();
  }

  Future<void> _saveProfile(String name, String phone) async {
    final currentUser = _authService.currentUser;

    if (currentUser == null) return;

    setState(() => isSaving = true);

    try {
      await _userService.updateProfile(
        uid: currentUser.uid,
        name: name,
        phone: phone,
      );

      await _loadProfile();

      if (!mounted) return;
      _showMessage('Profile updated successfully.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Profile update failed: $e');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _authService.currentUser?.email;

    if (email == null) {
      _showMessage('Email address not found.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      _showMessage('Password reset link sent to $email');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to send reset email: $e');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Logout failed: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _roleName(String role) {
    if (role == 'admin' || role == 'administrator') {
      return 'Administrator';
    }

    return role.isEmpty ? 'Member' : role.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile & Settings')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Profile not found.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = user!;
    final role = _roleName(profile.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 28 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.navy,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 43,
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              profile.name.isNotEmpty
                                  ? profile.name[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            profile.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            role,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: isSaving ? null : _editProfile,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Profile'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          if (isSaving) ...[
                            const SizedBox(height: 10),
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InfoTile(
                      icon: Icons.person_outline,
                      title: 'Full Name',
                      value: profile.name,
                    ),
                    _InfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email Address',
                      value: profile.email,
                    ),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Phone Number',
                      value: profile.phone.isEmpty ? 'Not added' : profile.phone,
                    ),
                    _InfoTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Account Role',
                      value: role,
                    ),
                    _InfoTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Account Status',
                      value: profile.accountStatus.toUpperCase(),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        value: notificationsEnabled,
                        activeThumbColor: AppTheme.primary,
                        secondary: const Icon(
                          Icons.notifications_active_outlined,
                          color: AppTheme.navy,
                        ),
                        title: const Text(
                          'Notifications',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Enable app notification alerts',
                        ),
                        onChanged: (value) {
                          setState(() => notificationsEnabled = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: 'About PSMS',
                      subtitle: 'Professional Student Management System',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'PSMS',
                          applicationVersion: '1.0.0',
                          applicationLegalese:
                              'Smart Management, Better Education',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      icon: Icons.security_outlined,
                      title: 'Account Security',
                      subtitle: 'Send password reset link to your email',
                      onTap: _resetPassword,
                    ),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out from your account',
                      onTap: _logout,
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'PSMS Version 1.0.0',
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.navy, size: 23),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w600,
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: Icon(icon, color: AppTheme.navy, size: 23),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 15),
        onTap: onTap,
      ),
    );
  }
}
