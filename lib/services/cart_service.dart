import '../models/cart_model.dart';
import '../models/mango_model.dart';

class CartService {
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Add to cart
  Future<bool> addToCart(MangoModel mango, int quantity) async {
    try {
      final existingIndex = _items.indexWhere((item) => item.mango.id == mango.id);

      if (existingIndex != -1) {
        // Update quantity if item already exists
        _items[existingIndex].quantity += quantity;
      } else {
        // Add new item
        _items.add(CartItemModel(mango: mango, quantity: quantity));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Remove from cart
  Future<bool> removeFromCart(String mangoId) async {
    try {
      _items.removeWhere((item) => item.mango.id == mangoId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update quantity
  Future<bool> updateQuantity(String mangoId, int quantity) async {
    try {
      final index = _items.indexWhere((item) => item.mango.id == mangoId);
      if (index != -1) {
        if (quantity <= 0) {
          _items.removeAt(index);
        } else {
          _items[index].quantity = quantity;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    try {
      _items.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get cart item count for a specific mango
  int getItemQuantity(String mangoId) {
    final item = _items.firstWhere(
      (item) => item.mango.id == mangoId,
      orElse: () => CartItemModel(
        mango: MangoModel(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          stock: 0,
          category: '',
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }
}
