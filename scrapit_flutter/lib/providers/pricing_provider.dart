import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pricing_model.dart';
import '../services/api_service.dart';

class PricingProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<PricingModel> _pricing = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Countdown timer for "Prices update in"
  int _secondsRemaining = 2 * 3600 + 45 * 60 + 30; // 02:45:30
  Timer? _countdownTimer;

  PricingProvider({required ApiService apiService}) : _apiService = apiService {
    _startCountdown();
  }

  List<PricingModel> get pricing => _pricing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get secondsRemaining => _secondsRemaining;

  String get formattedCountdown {
    final h = (_secondsRemaining ~/ 3600).toString().padLeft(2, '0');
    final m = ((_secondsRemaining % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$h : $m : $s';
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
      } else {
        _secondsRemaining = 3 * 3600; // Reset to 3 hours
      }
      notifyListeners();
    });
  }

  Future<void> loadPricing() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pricing = await _apiService.getPricing();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
