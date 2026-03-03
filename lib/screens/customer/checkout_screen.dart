import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _addressController.text = user.address;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();
      final orderProvider = context.read<OrderProvider>();

      if (authProvider.currentUser == null) {
        Helpers.showSnackBar(context, 'Please login first', isError: true);
        return;
      }

      Helpers.showLoadingDialog(context);

      final order = await orderProvider.placeOrder(
        userId: authProvider.currentUser!.id,
        customerName: authProvider.currentUser!.name,
        items: cartProvider.items,
        shippingAddress: _addressController.text.trim(),
      );

      if (mounted) {
        Helpers.hideLoadingDialog(context);

        if (order != null) {
          await cartProvider.clearCart();
          Helpers.showSnackBar(context, AppStrings.orderPlaced);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          Helpers.showSnackBar(
            context,
            orderProvider.errorMessage ?? 'Failed to place order',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.checkout),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ...cartProvider.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('${item.mango.name} x ${item.quantity}'),
                                  ),
                                  Text(Helpers.formatCurrency(item.totalPrice)),
                                ],
                              ),
                            );
                          }),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.total,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                Helpers.formatCurrency(cartProvider.totalAmount),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Shipping Address',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              CustomTextfield(
                controller: _addressController,
                label: 'Address',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shipping address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Place Order',
                onPressed: _placeOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
