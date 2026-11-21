
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final user = await _userService.getUser(uid);

    if (user == null) {
      await _auth.signOut();
      throw Exception('User profile not found.');
    }

    if (user.accountStatus != 'approved') {
      await _auth.signOut();
      throw Exception('Your account is pending approval.');
    }

    if (user.role != 'admin' && user.role != 'administrator') {
      await _auth.signOut();
      throw Exception('You are not authorized as an Admin.');
    }

    return user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
