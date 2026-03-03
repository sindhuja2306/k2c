import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../core/utils/helpers.dart';
import '../providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildCartImage(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.mango.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatCurrency(cartItem.mango.price),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          cartProvider.decrementQuantity(cartItem.mango.id);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (cartItem.quantity < cartItem.mango.stock) {
                            cartProvider.incrementQuantity(cartItem.mango.id);
                          } else {
                            Helpers.showSnackBar(
                              context,
                              'Maximum stock reached',
                              isError: true,
                            );
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    cartProvider.removeFromCart(cartItem.mango.id);
                  },
                ),
                Text(
                  Helpers.formatCurrency(cartItem.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartImage() {
    const double imageSize = 80;

    // If admin uploaded imageBytes, use that
    if (cartItem.mango.imageBytes != null) {
      return Image.memory(
        cartItem.mango.imageBytes!,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
      );
    }

    // Otherwise fall back to network image
    if (cartItem.mango.imageUrl.isNotEmpty) {
      return Image.network(
        cartItem.mango.imageUrl,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: imageSize,
            height: imageSize,
            color: Colors.grey[300],
            child: const Icon(Icons.image),
          );
        },
      );
    }

    // No image available
    return Container(
      width: imageSize,
      height: imageSize,
      color: Colors.grey[300],
      child: const Icon(Icons.image),
    );
  }
}
