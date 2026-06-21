class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? photo;
  final String? emailVerifiedAt;
  final bool isAdmin;
  final String createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.photo,
    this.emailVerifiedAt,
    this.isAdmin = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'photo': photo,
      'email_verified_at': emailVerifiedAt,
      'is_admin': isAdmin ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      phone: map['phone'] as String?,
      photo: map['photo'] as String?,
      emailVerifiedAt: map['email_verified_at'] as String?,
      isAdmin: (map['is_admin'] as int?) == 1,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? photo,
    String? emailVerifiedAt,
    bool? isAdmin,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
