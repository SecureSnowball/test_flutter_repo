class User {
  final int? id;
  final String name;
  final String? email;
  final String? mobile;
  final bool? emailVerified;

  User({
    this.id,
    required this.name,
    this.mobile,
    this.email,
    this.emailVerified,
  });

  factory User.fromJson(Map json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      emailVerified: json['emailVerifiedAt'] != null,
    );
  }
}