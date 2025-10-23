class User {
  final String name;
  final String email;
  final String? image;
  final String? token;

  User({required this.name, required this.email, this.image, this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      image: json['image'],
      token: json['token'],
    );
  }
}
