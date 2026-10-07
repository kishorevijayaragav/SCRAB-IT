import 'package:flutter_test/flutter_test.dart';
import 'package:scrapit_flutter/core/utils/formatters.dart';
import 'package:scrapit_flutter/core/utils/validators.dart';
import 'package:scrapit_flutter/models/user_model.dart';
import 'package:scrapit_flutter/models/inventory_item.dart';
import 'package:scrapit_flutter/models/scan_result.dart';
import 'package:scrapit_flutter/models/pricing_model.dart';
import 'package:scrapit_flutter/models/buyer_model.dart';

void main() {
  group('Formatters & Validators Unit Tests', () {
    test('Formatters.money formats Indian Rupee correctly', () {
      expect(Formatters.money(1536), contains('1,536'));
      expect(Formatters.money(0), contains('0'));
    });

    test('Formatters.kg formats kilograms correctly', () {
      expect(Formatters.kg(3.2), '3.2 kg');
      expect(Formatters.kg(5), '5 kg');
    });

    test('Validators.email validates correctly', () {
      expect(Validators.email('admin@scrapit.com'), isNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('Validators.password enforces 6 character minimum', () {
      expect(Validators.password('scrapit123'), isNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });
  });

  group('Model Serialization Tests', () {
    test('UserModel.fromJson parses successfully', () {
      final json = {
        'id': 1,
        'name': 'Aditya Kumar',
        'role': 'Scrap Manager',
        'email': 'admin@scrapit.com',
      };
      final user = UserModel.fromJson(json);
      expect(user.id, 1);
      expect(user.name, 'Aditya Kumar');
      expect(user.initials, 'AK');
    });

    test('InventoryItem.fromJson parses correctly', () {
      final json = {
        'id': 'inv1',
        'material': 'Aluminium',
        'category': 'Metal',
        'quantity': 2,
        'pricePerKg': 180,
        'estimatedValue': 360,
        'date': '12 May 2026',
      };
      final item = InventoryItem.fromJson(json);
      expect(item.id, 'inv1');
      expect(item.material, 'Aluminium');
      expect(item.quantity, 2.0);
      expect(item.estimatedValue, 360.0);
    });

    test('ScanResult.fromJson parses correctly', () {
      final json = {
        'material': 'Brass',
        'category': 'Metal',
        'confidence': 94,
        'quantity': 3.2,
        'pricePerKg': 480,
        'estimatedValue': 1536,
        'date': '16 Sept 2026',
      };
      final result = ScanResult.fromJson(json);
      expect(result.material, 'Brass');
      expect(result.confidence, 94);
      expect(result.estimatedValue, 1536.0);
    });

    test('PricingModel.fromJson parses correctly', () {
      final json = {
        'material': 'Copper',
        'pricePerKg': 720,
        'changePercent': 3.1,
        'trend': 'up',
        'updatedAt': '2026-09-15T12:00:02.553Z',
      };
      final pricing = PricingModel.fromJson(json);
      expect(pricing.material, 'Copper');
      expect(pricing.pricePerKg, 720.0);
      expect(pricing.isUp, isTrue);
    });

    test('BuyerModel.fromJson parses correctly', () {
      final json = {
        'id': 'b1',
        'name': 'Green Scrap Traders',
        'distance': '2.1 km away',
        'materials': ['Aluminium', 'Copper'],
        'rating': 4.5,
        'reviews': 120,
        'initials': 'GS',
        'phone': '+919876543210',
      };
      final buyer = BuyerModel.fromJson(json);
      expect(buyer.name, 'Green Scrap Traders');
      expect(buyer.materials.length, 2);
    });
  });
}
