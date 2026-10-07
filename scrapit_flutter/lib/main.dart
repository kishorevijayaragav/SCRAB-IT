import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/buyers_provider.dart';
import 'providers/pricing_provider.dart';
import 'providers/history_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize persistent storage
  final storageService = await StorageService.init();

  // 2. Initialize API Client & Service
  final apiClient = ApiClient(storageService: storageService);
  final apiService = ApiService(apiClient);

  // 3. Initialize Auth provider & session
  final authProvider = AuthProvider(
    apiService: apiService,
    storageService: storageService,
  );
  apiClient.onUnauthorized = authProvider.handleSessionExpired;

  try {
    await authProvider.init();
  } catch (_) {
    // Fallback if auth initialization fails on startup
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<InventoryProvider>(
          create: (_) => InventoryProvider(apiService: apiService),
        ),
        ChangeNotifierProvider<BuyersProvider>(
          create: (_) => BuyersProvider(apiService: apiService),
        ),
        ChangeNotifierProvider<PricingProvider>(
          create: (_) => PricingProvider(apiService: apiService),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(apiService: apiService),
        ),
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => NotificationsProvider(apiService: apiService),
        ),
        ChangeNotifierProvider<ScanProvider>(
          create: (_) => ScanProvider(apiService: apiService),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
      ],
      child: const ScrapItApp(),
    ),
  );
}
