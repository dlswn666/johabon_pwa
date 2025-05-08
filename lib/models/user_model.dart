class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin', 'member', 'guest'
  final DateTime createdAt;
  String? phoneNumber;
  String? address;
  bool? isApproved;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.phoneNumber,
    this.address,
    this.isApproved,
  });

  // JSON에서 User 객체로 변환
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      isApproved: json['isApproved'],
    );
  }

  // User 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
      'isApproved': isApproved,
    };
  }

  // User 객체 복사하여 수정된 버전 반환
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    String? phoneNumber,
    String? address,
    bool? isApproved,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isApproved: isApproved ?? this.isApproved,
    );
  }
} 