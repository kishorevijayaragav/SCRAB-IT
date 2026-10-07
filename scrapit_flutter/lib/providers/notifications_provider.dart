import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  NotificationsProvider({required ApiService apiService}) : _apiService = apiService;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasUnread => _unreadCount > 0;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.getNotifications();
      _notifications = res.notifications;
      _unreadCount = res.unread;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].read) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
      try {
        await _apiService.markNotificationRead(id);
      } catch (_) {}
    }
  }

  Future<void> markAllRead() async {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _apiService.markAllNotificationsRead();
    } catch (_) {}
  }
}
