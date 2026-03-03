import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mango_model.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';

class MangoDetailsScreen extends StatefulWidget {
  final MangoModel mango;

  const MangoDetailsScreen({super.key, required this.mango});

  @override
  State<MangoDetailsScreen> createState() => _MangoDetailsScreenState();
}

class _MangoDetailsScreenState extends State<MangoDetailsScreen> {
  int _quantity = 1;

  void _incrementQuantity() {
    if (_quantity < widget.mango.stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _addToCart() async {
    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.addToCart(widget.mango, _quantity);

    if (mounted) {
      if (success) {
        Helpers.showSnackBar(context, 'Added to cart!');
      } else {
        Helpers.showSnackBar(context, 'Failed to add to cart', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mango.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'mango_${widget.mango.id}',
              child: _buildDetailImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.mango.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.mango.category,
                          style: TextStyle(color: Colors.green[800]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.mango.rating}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Helpers.formatCurrency(widget.mango.price),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.mango.description),
                  const SizedBox(height: 16),
                  Text(
                    'Stock: ${widget.mango.stock} kg',
                    style: TextStyle(
                      color: widget.mango.stock > 10 ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.quantity,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _decrementQuantity,
                          ),
                          Text(
                            '$_quantity',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _incrementQuantity,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: AppStrings.addToCart,
                    onPressed: _addToCart,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailImage() {
    const double imageHeight = 300;

    // If admin uploaded imageBytes, use that
    if (widget.mango.imageBytes != null) {
      return Image.memory(
        widget.mango.imageBytes!,
        height: imageHeight,
        fit: BoxFit.cover,
      );
    }

    // Otherwise fall back to network image
    if (widget.mango.imageUrl.isNotEmpty) {
      return Image.network(
        widget.mango.imageUrl,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: imageHeight,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 100),
          );
        },
      );
    }

    // No image available
    return Container(
      height: imageHeight,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 100),
    );
  }
}
