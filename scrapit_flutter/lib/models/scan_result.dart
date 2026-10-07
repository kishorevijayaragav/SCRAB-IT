class ScanResult {
  final String material;
  final String category;
  final int confidence;
  final double quantity;
  final double pricePerKg;
  final double estimatedValue;
  final String? imageUrl;
  final String date;

  ScanResult({
    required this.material,
    required this.category,
    required this.confidence,
    required this.quantity,
    required this.pricePerKg,
    required this.estimatedValue,
    this.imageUrl,
    required this.date,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      material: json['material']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Metal',
      confidence: json['confidence'] is int ? json['confidence'] : int.tryParse(json['confidence']?.toString() ?? '90') ?? 90,
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toDouble() : double.tryParse(json['quantity']?.toString() ?? '1.0') ?? 1.0,
      pricePerKg: (json['pricePerKg'] is num) ? (json['pricePerKg'] as num).toDouble() : double.tryParse(json['pricePerKg']?.toString() ?? '0') ?? 0.0,
      estimatedValue: (json['estimatedValue'] is num) ? (json['estimatedValue'] as num).toDouble() : double.tryParse(json['estimatedValue']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['imageUrl']?.toString(),
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material': material,
      'category': category,
      'confidence': confidence,
      'quantity': quantity,
      'pricePerKg': pricePerKg,
      'estimatedValue': estimatedValue,
      'imageUrl': imageUrl,
      'date': date,
    };
  }
}
