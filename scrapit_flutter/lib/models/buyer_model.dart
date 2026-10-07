class BuyerModel {
  final String id;
  final String name;
  final String distance;
  final List<String> materials;
  final double rating;
  final int reviews;
  final String initials;
  final String? phone;

  BuyerModel({
    required this.id,
    required this.name,
    required this.distance,
    required this.materials,
    required this.rating,
    required this.reviews,
    required this.initials,
    this.phone,
  });

  factory BuyerModel.fromJson(Map<String, dynamic> json) {
    return BuyerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      materials: (json['materials'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviews: json['reviews'] is int ? json['reviews'] : int.tryParse(json['reviews']?.toString() ?? '0') ?? 0,
      initials: json['initials']?.toString() ?? '',
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'distance': distance,
      'materials': materials,
      'rating': rating,
      'reviews': reviews,
      'initials': initials,
      'phone': phone,
    };
  }
}
