import 'mango_model.dart';

class CartItemModel {
  final MangoModel mango;
  int quantity;

  CartItemModel({
    required this.mango,
    required this.quantity,
  });

  double get totalPrice => mango.price * quantity;

  // From JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      mango: MangoModel.fromJson(json['mango']),
      quantity: json['quantity'] ?? 1,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'mango': mango.toJson(),
      'quantity': quantity,
    };
  }
}

class CartModel {
  final List<CartItemModel> items;

  CartModel({required this.items});

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // From JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
