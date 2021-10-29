class User {
  final int? id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: DateTime.parse((json['emailVerifiedAt'])),
    );
  }

  Map toTokenJson() {
    return {
      'id': id!,
      'name': name,
      'email': email,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
    };
  }

  factory User.fromTokenJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['emailVerifiedAt'] != null
          ? DateTime.parse((json['emailVerifiedAt']))
          : null,
    );
  }
}
