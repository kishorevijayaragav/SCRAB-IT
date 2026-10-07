class UserModel {
  final int id;
  final String name;
  final String role;
  final String email;
  final String? phone;
  final String? business;
  final String? gst;
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.phone,
    this.business,
    this.gst,
    this.address,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? 'Scrap Manager',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      business: json['business']?.toString(),
      gst: json['gst']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'business': business,
      'gst': gst,
      'address': address,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? role,
    String? email,
    String? phone,
    String? business,
    String? gst,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      business: business ?? this.business,
      gst: gst ?? this.gst,
      address: address ?? this.address,
    );
  }
}
