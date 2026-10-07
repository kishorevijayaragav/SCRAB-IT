import 'package:flutter/foundation.dart';
import '../models/buyer_model.dart';
import '../services/api_service.dart';

class BuyersProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<BuyerModel> _buyers = [];
  bool _isLoading = false;
  String? _errorMessage;

  BuyersProvider({required ApiService apiService}) : _apiService = apiService;

  List<BuyerModel> get buyers => _buyers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBuyers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _buyers = await _apiService.getBuyers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
