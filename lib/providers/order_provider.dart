import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Place order
  Future<OrderModel?> placeOrder({
    required String userId,
    required String customerName,
    required List<CartItemModel> items,
    required String shippingAddress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.placeOrder(
        userId: userId,
        customerName: customerName,
        items: items,
        shippingAddress: shippingAddress,
      );
      if (order != null) {
        _orders.add(order);
      }
      return order;
    } catch (e) {
      _errorMessage = 'Failed to place order: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user orders
  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getUserOrders(userId);
    } catch (e) {
      _errorMessage = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all orders (Admin)
  Future<void> loadAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getAllOrders();
    } catch (e) {
      _errorMessage = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get order by ID
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Update order status (Admin)
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _orderService.updateOrderStatus(orderId, status);
      if (success) {
        // Reload orders to get updated data
        await loadAllOrders();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update order: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _orderService.cancelOrder(orderId);
      return success;
    } catch (e) {
      _errorMessage = 'Failed to cancel order: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set delivery date for an order (Admin)
  Future<bool> setDeliveryDate(String orderId, DateTime deliveryDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _orderService.setDeliveryDate(orderId, deliveryDate);
      if (success) {
        // Reload orders to show updated delivery date
        await loadAllOrders();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to set delivery date: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
