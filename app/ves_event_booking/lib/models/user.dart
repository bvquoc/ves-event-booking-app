class User {
  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final String? phone;

  User({required this.id, required this.email, this.name, this.avatar, this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      phone: json['phone'],
    );
  }
}