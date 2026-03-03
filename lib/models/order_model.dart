import 'cart_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderModel {
  final String id;
  final String userId;
  final String customerName; // Customer's full name
  final List<CartItemModel> items;
  final double totalAmount;
  OrderStatus status;
  final DateTime orderDate;
  final String shippingAddress;
  final String? trackingNumber;
  DateTime? expectedDeliveryDate; // Admin sets this
  final List<OrderStatusUpdate> statusUpdates = []; // Track all updates

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.shippingAddress,
    this.trackingNumber,
    this.expectedDeliveryDate,
  }) {
    // Initialize with first status
    statusUpdates.add(
      OrderStatusUpdate(
        status: status,
        timestamp: orderDate,
        message: 'Order placed',
      ),
    );
  }

  // From JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      customerName: json['customerName'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      shippingAddress: json['shippingAddress'] ?? '',
      trackingNumber: json['trackingNumber'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'orderDate': orderDate.toIso8601String(),
      'shippingAddress': shippingAddress,
      'trackingNumber': trackingNumber,
    };
  }

  String get statusString {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderStatusUpdate {
  final OrderStatus status;
  final DateTime timestamp;
  final String message;

  OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    required this.message,
  });
}

