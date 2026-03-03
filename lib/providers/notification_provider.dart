import 'package:flutter/foundation.dart';

class AppNotification {
  final String id;
  final String message;
  final bool isError;
  final DateTime createdAt;
  final String? orderId;
  final String? title;
  bool isRead;

  AppNotification({
    required this.message,
    this.isError = false,
    DateTime? createdAt,
    this.orderId,
    this.title,
    this.isRead = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        id = DateTime.now().millisecondsSinceEpoch.toString();
}

class NotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get count => _notifications.length;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(
    String message, {
    bool isError = false,
    String? orderId,
    String? title,
  }) {
    if (message.trim().isEmpty) return;

    _notifications.insert(
      0,
      AppNotification(
        message: message,
        isError: isError,
        orderId: orderId,
        title: title,
        isRead: false,
      ),
    );
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  List<AppNotification> getNotificationsForOrder(String orderId) {
    return _notifications.where((n) => n.orderId == orderId).toList();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
