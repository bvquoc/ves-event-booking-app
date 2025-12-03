class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? avatar;
  final DateTime? dateOfBirth; // Có trong register response
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.avatar,
    this.dateOfBirth,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      avatar: json['avatar'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
