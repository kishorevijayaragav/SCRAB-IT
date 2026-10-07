import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/user_model.dart';
import '../models/inventory_item.dart';
import '../models/buyer_model.dart';
import '../models/pricing_model.dart';
import '../models/history_item.dart';
import '../models/notification_model.dart';
import '../models/scan_result.dart';
import '../models/app_settings.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  String get baseUrl => _client.currentBaseUrl;

  Future<bool> checkHealth() async {
    try {
      final res = await _client.get(ApiConstants.health);
      return res.data?['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // --- Auth ---
  Future<({String token, UserModel user})> login(String email, String password) async {
    final res = await _client.post(
      ApiConstants.login,
      data: {'email': email.trim(), 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Login failed');
    }
    final token = data['token'].toString();
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (token: token, user: user);
  }

  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final res = await _client.post(
      ApiConstants.register,
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Registration failed');
    }
    final token = data['token'].toString();
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (token: token, user: user);
  }

  Future<UserModel> getMe() async {
    final res = await _client.get(ApiConstants.me);
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to load profile');
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {}
  }

  // --- Uploads & AI Scan ---
  Future<String?> uploadImage(String filePath, String fileName) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    String mime = 'image/jpeg';
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) mime = 'image/png';
    if (lower.endsWith('.webp')) mime = 'image/webp';

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: MediaType.parse(mime),
      ),
    });

    final res = await _client.post(ApiConstants.uploads, data: formData);
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true && data['file'] != null) {
      return data['file']['url']?.toString();
    }
    return null;
  }

  Future<ScanResult> analyzeScan({String? imageUrl, required String filename}) async {
    final res = await _client.post(
      ApiConstants.scanAnalyze,
      data: {
        if (imageUrl != null) 'imageUrl': imageUrl,
        'filename': filename,
      },
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true || data['result'] == null) {
      throw ApiException(data['error']?.toString() ?? 'Scan analysis failed');
    }
    return ScanResult.fromJson(data['result'] as Map<String, dynamic>);
  }

  // --- Inventory ---
  Future<List<InventoryItem>> getInventory() async {
    final res = await _client.get(ApiConstants.inventory);
    final data = res.data as Map<String, dynamic>;
    final list = data['inventory'] as List<dynamic>? ?? [];
    return list.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<InventoryItem> addInventory({
    required String material,
    required double quantity,
    required double pricePerKg,
    String? image,
    int? confidence,
  }) async {
    final res = await _client.post(
      ApiConstants.inventory,
      data: {
        'material': material,
        'quantity': quantity,
        'pricePerKg': pricePerKg,
        if (image != null) 'image': image,
        if (confidence != null) 'confidence': confidence,
      },
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true || data['item'] == null) {
      throw ApiException(data['error']?.toString() ?? 'Failed to add item');
    }
    return InventoryItem.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<InventoryItem> updateInventory(
    String id, {
    String? material,
    double? quantity,
    double? pricePerKg,
  }) async {
    final res = await _client.put(
      ApiConstants.inventoryItem(id),
      data: {
        if (material != null) 'material': material,
        if (quantity != null) 'quantity': quantity,
        if (pricePerKg != null) 'pricePerKg': pricePerKg,
      },
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true || data['item'] == null) {
      throw ApiException(data['error']?.toString() ?? 'Failed to update item');
    }
    return InventoryItem.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<void> deleteInventory(String id) async {
    final res = await _client.delete(ApiConstants.inventoryItem(id));
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to delete item');
    }
  }

  // --- Buyers ---
  Future<List<BuyerModel>> getBuyers() async {
    final res = await _client.get(ApiConstants.buyers);
    final data = res.data as Map<String, dynamic>;
    final list = data['buyers'] as List<dynamic>? ?? [];
    return list.map((e) => BuyerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Pricing ---
  Future<List<PricingModel>> getPricing() async {
    final res = await _client.get(ApiConstants.pricing);
    final data = res.data as Map<String, dynamic>;
    final list = data['pricing'] as List<dynamic>? ?? [];
    return list.map((e) => PricingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- History ---
  Future<List<HistoryItem>> getHistory() async {
    final res = await _client.get(ApiConstants.history);
    final data = res.data as Map<String, dynamic>;
    final list = data['history'] as List<dynamic>? ?? [];
    return list.map((e) => HistoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Notifications ---
  Future<({List<NotificationModel> notifications, int unread})> getNotifications() async {
    final res = await _client.get(ApiConstants.notifications);
    final data = res.data as Map<String, dynamic>;
    final list = data['notifications'] as List<dynamic>? ?? [];
    final unread = data['unread'] is int ? data['unread'] as int : 0;
    final notifications = list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (notifications: notifications, unread: unread);
  }

  Future<void> markNotificationRead(String id) async {
    await _client.put(ApiConstants.notificationRead(id));
  }

  Future<void> markAllNotificationsRead() async {
    await _client.put(ApiConstants.markAllRead);
  }

  // --- Settings ---
  Future<AppSettings> getSettings() async {
    final res = await _client.get(ApiConstants.settings);
    final data = res.data as Map<String, dynamic>;
    return AppSettings.fromJson(data['settings'] as Map<String, dynamic>? ?? {});
  }

  Future<AppSettings> updateSettings(AppSettings settings) async {
    final res = await _client.put(ApiConstants.settings, data: settings.toJson());
    final data = res.data as Map<String, dynamic>;
    return AppSettings.fromJson(data['settings'] as Map<String, dynamic>? ?? {});
  }

  // --- Contact ---
  Future<void> submitContact({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final res = await _client.post(
      ApiConstants.contact,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'subject': subject.trim(),
        'message': message.trim(),
      },
    );
    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to send message');
    }
  }
}
