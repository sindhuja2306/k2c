import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../models/mango_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> get items => _cartService.items;
  double get totalAmount => _cartService.totalAmount;
  int get totalItems => _cartService.totalItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Add to cart
  Future<bool> addToCart(MangoModel mango, int quantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _cartService.addToCart(mango, quantity);
      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove from cart
  Future<bool> removeFromCart(String mangoId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _cartService.removeFromCart(mangoId);
      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update quantity
  Future<bool> updateQuantity(String mangoId, int quantity) async {
    try {
      final success = await _cartService.updateQuantity(mangoId, quantity);
      notifyListeners();
      return success;
    } catch (e) {
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _cartService.clearCart();
      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get item quantity
  int getItemQuantity(String mangoId) {
    return _cartService.getItemQuantity(mangoId);
  }

  // Increment quantity
  Future<void> incrementQuantity(String mangoId) async {
    final currentQuantity = getItemQuantity(mangoId);
    await updateQuantity(mangoId, currentQuantity + 1);
  }

  // Decrement quantity
  Future<void> decrementQuantity(String mangoId) async {
    final currentQuantity = getItemQuantity(mangoId);
    if (currentQuantity > 1) {
      await updateQuantity(mangoId, currentQuantity - 1);
    } else {
      await removeFromCart(mangoId);
    }
  }
}
