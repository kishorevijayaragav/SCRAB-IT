class InventoryItem {
  final String id;
  final String material;
  final String category;
  final double quantity;
  final double pricePerKg;
  final double estimatedValue;
  final String date;
  final String? image;
  final int? confidence;

  InventoryItem({
    required this.id,
    required this.material,
    required this.category,
    required this.quantity,
    required this.pricePerKg,
    required this.estimatedValue,
    required this.date,
    this.image,
    this.confidence,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toDouble() : double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      pricePerKg: (json['pricePerKg'] is num) ? (json['pricePerKg'] as num).toDouble() : double.tryParse(json['pricePerKg']?.toString() ?? '0') ?? 0.0,
      estimatedValue: (json['estimatedValue'] is num) ? (json['estimatedValue'] as num).toDouble() : double.tryParse(json['estimatedValue']?.toString() ?? '0') ?? 0.0,
      date: json['date']?.toString() ?? '',
      image: json['image']?.toString(),
      confidence: json['confidence'] is int ? json['confidence'] : int.tryParse(json['confidence']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material': material,
      'category': category,
      'quantity': quantity,
      'pricePerKg': pricePerKg,
      'estimatedValue': estimatedValue,
      'date': date,
      'image': image,
      'confidence': confidence,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? material,
    String? category,
    double? quantity,
    double? pricePerKg,
    double? estimatedValue,
    String? date,
    String? image,
    int? confidence,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      material: material ?? this.material,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      date: date ?? this.date,
      image: image ?? this.image,
      confidence: confidence ?? this.confidence,
    );
  }
}
