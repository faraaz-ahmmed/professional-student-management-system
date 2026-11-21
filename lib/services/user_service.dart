
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _users.doc(uid).update({
      'role': role,
    });
  }

  Future<void> updateAccountStatus(
    String uid,
    String status,
  ) async {
    await _users.doc(uid).update({
      'accountStatus': status,
    });
  }
}
