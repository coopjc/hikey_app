class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String email;
  final String displayName;
  final int age;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'email': email,
    'display_name': displayName,
    'age': age,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
