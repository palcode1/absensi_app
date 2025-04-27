class UserModel {
  final int? id; // Auto increment ID dari SQLite
  final String uid; // UID unik untuk identifikasi user
  final String name;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }
}
