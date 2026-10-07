import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // Default host determination:
  // - Android Emulator: 10.0.2.2
  // - iOS Simulator / Web / Desktop: localhost
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  // Endpoints
  static const String health = '/api/health';
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String uploads = '/api/uploads';
  static const String scanAnalyze = '/api/scan/analyze';
  static const String inventory = '/api/inventory';
  static const String buyers = '/api/buyers';
  static const String pricing = '/api/pricing';
  static const String history = '/api/history';
  static const String notifications = '/api/notifications';
  static const String markAllRead = '/api/notifications/read-all';
  static const String settings = '/api/settings';
  static const String contact = '/api/contact';

  static String notificationRead(String id) => '/api/notifications/$id/read';
  static String inventoryItem(String id) => '/api/inventory/$id';
}
