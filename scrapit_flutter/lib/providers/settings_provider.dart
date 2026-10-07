import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  AppSettings _settings = AppSettings();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  SettingsProvider({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  String? get customBaseUrl => _storageService.getCustomBaseUrl();

  Future<void> setCustomBaseUrl(String? url) async {
    await _storageService.setCustomBaseUrl(url);
    notifyListeners();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _apiService.getSettings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNotificationSetting({
    bool? pushScan,
    bool? priceAlerts,
    bool? invReminder,
  }) async {
    final nextNotif = _settings.notifications.copyWith(
      pushScan: pushScan,
      priceAlerts: priceAlerts,
      invReminder: invReminder,
    );
    _settings = _settings.copyWith(notifications: nextNotif);
    notifyListeners();

    try {
      await _apiService.updateSettings(_settings);
    } catch (_) {}
  }

  Future<void> updatePreferences({
    String? language,
    String? currency,
    String? unit,
  }) async {
    final nextPref = _settings.preferences.copyWith(
      language: language,
      currency: currency,
      unit: unit,
    );
    _settings = _settings.copyWith(preferences: nextPref);
    notifyListeners();

    try {
      await _apiService.updateSettings(_settings);
    } catch (_) {}
  }
}
