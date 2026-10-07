class PricingModel {
  final String material;
  final double pricePerKg;
  final double changePercent;
  final String trend; // 'up' or 'down'
  final String updatedAt;

  PricingModel({
    required this.material,
    required this.pricePerKg,
    required this.changePercent,
    required this.trend,
    required this.updatedAt,
  });

  bool get isUp => trend.toLowerCase() == 'up' || changePercent >= 0;

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      material: json['material']?.toString() ?? '',
      pricePerKg: (json['pricePerKg'] is num) ? (json['pricePerKg'] as num).toDouble() : double.tryParse(json['pricePerKg']?.toString() ?? '0') ?? 0.0,
      changePercent: (json['changePercent'] is num) ? (json['changePercent'] as num).toDouble() : double.tryParse(json['changePercent']?.toString() ?? '0') ?? 0.0,
      trend: json['trend']?.toString() ?? 'up',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material': material,
      'pricePerKg': pricePerKg,
      'changePercent': changePercent,
      'trend': trend,
      'updatedAt': updatedAt,
    };
  }
}
