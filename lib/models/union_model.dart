class Union {
  final String id;
  final String name;
  final String? logoUrl;
  final String? address;
  final String? phone;
  final String? email;
  final String? homepage; // URL 슬러그
  final DateTime createdAt;

  Union({
    required this.id,
    required this.name,
    this.logoUrl,
    this.address,
    this.phone,
    this.email,
    this.homepage,
    required this.createdAt,
  });

  factory Union.fromJson(Map<String, dynamic> json) {
    return Union(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      homepage: json['homepage'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'address': address,
      'phone': phone,
      'email': email,
      'homepage': homepage,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 