import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../services/api_service.dart';

class InventoryProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  InventoryProvider({required ApiService apiService}) : _apiService = apiService;

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<InventoryItem> get filteredItems {
    return _items.filter((item) {
      final matchesCat = _selectedCategory == 'All' || item.category == _selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          item.material.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadInventory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _apiService.getInventory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addItem({
    required String material,
    required double quantity,
    required double pricePerKg,
    String? image,
    int? confidence,
  }) async {
    try {
      final newItem = await _apiService.addInventory(
        material: material,
        quantity: quantity,
        pricePerKg: pricePerKg,
        image: image,
        confidence: confidence,
      );
      _items.insert(0, newItem);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(
    String id, {
    String? material,
    double? quantity,
    double? pricePerKg,
  }) async {
    try {
      final updated = await _apiService.updateInventory(
        id,
        material: material,
        quantity: quantity,
        pricePerKg: pricePerKg,
      );
      final index = _items.indexWhere((it) => it.id == id);
      if (index != -1) {
        _items[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _apiService.deleteInventory(id);
      _items.removeWhere((it) => it.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

extension IterableExt<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T element) test) sync* {
    for (final element in this) {
      if (test(element)) yield element;
    }
  }
}
