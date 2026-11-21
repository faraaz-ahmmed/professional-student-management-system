
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String accountStatus;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'member',
    this.accountStatus = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'accountStatus': accountStatus,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'member',
      accountStatus: map['accountStatus'] ?? 'pending',
    );
  }
}
