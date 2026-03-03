import '../models/order_model.dart';
import '../models/cart_model.dart';

class OrderService {
  // Singleton pattern
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  // Place order
  Future<OrderModel?> placeOrder({
    required String userId,
    required String customerName,
    required List<CartItemModel> items,
    required String shippingAddress,
  }) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        customerName: customerName,
        items: items,
        totalAmount: items.fold(0.0, (sum, item) => sum + item.totalPrice),
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        shippingAddress: shippingAddress,
      );

      _orders.add(order);
      return order;
    } catch (e) {
      return null;
    }
  }

  // Get all orders for a user
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
      return _orders.where((order) => order.userId == userId).toList();
    } catch (e) {
      return [];
    }
  }

  // Get all orders (Admin only)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
      return _orders;
    } catch (e) {
      return [];
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      // TODO: Implement API call
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Update order status (Admin only)
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final order = _orders[index];
        order.status = newStatus;
        
        // Add status update to audit trail
        final message = _getStatusMessage(newStatus);
        order.statusUpdates.add(
          OrderStatusUpdate(
            status: newStatus,
            timestamp: DateTime.now(),
            message: message,
          ),
        );
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Set expected delivery date for an order
  Future<bool> setDeliveryDate(String orderId, DateTime deliveryDate) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final order = _orders[index];
        order.expectedDeliveryDate = deliveryDate;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get status message based on status
  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order placed and pending confirmation';
      case OrderStatus.confirmed:
        return 'Order confirmed by admin';
      case OrderStatus.processing:
        return 'Order is being processed';
      case OrderStatus.shipped:
        return 'Order has been shipped and is on the way';
      case OrderStatus.delivered:
        return 'Order has been delivered successfully';
      case OrderStatus.cancelled:
        return 'Order has been cancelled';
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
      return updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      return false;
    }
  }
}
