import 'package:flutter/foundation.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';

class HistoryProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<HistoryItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTab = 'Scans'; // 'Scans', 'Inventory', 'Transactions'

  HistoryProvider({required ApiService apiService}) : _apiService = apiService;

  List<HistoryItem> get allItems => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTab => _selectedTab;

  List<HistoryItem> get recentActivity => _items.take(3).toList();

  List<HistoryItem> get itemsForSelectedTab {
    final typeFilter = switch (_selectedTab) {
      'Inventory' => 'inventory',
      'Transactions' => 'transaction',
      _ => 'scan',
    };
    return _items.where((it) => it.type == typeFilter).toList();
  }

  Map<String, List<HistoryItem>> get groupedItemsForSelectedTab {
    final list = itemsForSelectedTab;
    final map = <String, List<HistoryItem>>{};
    for (final it in list) {
      final g = it.group.isNotEmpty ? it.group : 'Today';
      map.putIfAbsent(g, () => []).add(it);
    }
    return map;
  }

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _apiService.getHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
