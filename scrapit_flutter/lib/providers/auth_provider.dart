import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  AuthProvider({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  String? get rememberedEmail => _storageService.getRememberedEmail();

  Future<void> init() async {
    _token = await _storageService.getToken();
    if (_token != null && _token!.isNotEmpty) {
      try {
        _currentUser = await _apiService.getMe();
      } catch (_) {
        // Token invalid or expired
        await _storageService.setToken(null);
        _token = null;
        _currentUser = null;
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final res = await _apiService.login(email, password);
      _token = res.token;
      _currentUser = res.user;
      await _storageService.setToken(res.token);
      if (rememberMe) {
        await _storageService.setRememberedEmail(email);
      } else {
        await _storageService.setRememberedEmail(null);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final res = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _token = res.token;
      _currentUser = res.user;
      await _storageService.setToken(res.token);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {}
    await _storageService.clearSession();
    _token = null;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void handleSessionExpired() {
    _storageService.setToken(null);
    _token = null;
    _currentUser = null;
    _errorMessage = 'Session expired. Please sign in again.';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
