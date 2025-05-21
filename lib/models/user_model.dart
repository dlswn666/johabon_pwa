class User {
  final String id;       // UUID
  final String? unionId; // UUID reference
  final String userType; // 'admin' 또는 'member'
  final String userId;   // 로그인용 아이디
  final String name;     // 사용자 실명
  final String? phone;   // 전화번호
  final DateTime? birth; // 생년월일
  final String? propertyLocation; // 권리 소재지
  final bool isApproved; // 관리자 승인 여부
  final DateTime createdAt; // 생성 일시

  User({
    required this.id,
    this.unionId,
    required this.userType,
    required this.userId,
    required this.name,
    this.phone,
    this.birth,
    this.propertyLocation,
    required this.isApproved,
    required this.createdAt,
  });

  // JSON에서 User 객체로 변환
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      unionId: json['union_id'],
      userType: json['user_type'] ?? 'member',
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      birth: json['birth'] != null ? DateTime.parse(json['birth']) : null,
      propertyLocation: json['property_location'],
      isApproved: json['is_approved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // User 객체에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'union_id': unionId,
      'user_type': userType,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'birth': birth?.toIso8601String(),
      'property_location': propertyLocation,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // User 객체 복사하여 수정된 버전 반환
  User copyWith({
    String? id,
    String? unionId,
    String? userType,
    String? userId,
    String? name,
    String? phone,
    DateTime? birth,
    String? propertyLocation,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      unionId: unionId ?? this.unionId,
      userType: userType ?? this.userType,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birth: birth ?? this.birth,
      propertyLocation: propertyLocation ?? this.propertyLocation,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 