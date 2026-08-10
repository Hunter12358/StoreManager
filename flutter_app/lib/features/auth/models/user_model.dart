class UserModel {
  final int userId;
  final String email;
  final String role;

  UserModel({
    required this.userId,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'],
      role: json['role'],
    );
  }
}