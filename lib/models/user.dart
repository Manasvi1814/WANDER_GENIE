class User {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final String? createdAt;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
      createdAt: map['createdAt'],
    );
  }

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
