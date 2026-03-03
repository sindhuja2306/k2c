import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mango_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/mango_model.dart';
import '../../models/order_model.dart';

enum AdminSection {
  overview,
  inventory,
  orders,
  users,
  analytics,
  settings,
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    this.initialSection = AdminSection.overview,
  });

  final AdminSection initialSection;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late AdminSection _section;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _inventorySearchController = TextEditingController();
  final TextEditingController _orderSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    // Load mangoes and orders from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MangoProvider>().loadMangoes();
      context.read<OrderProvider>().loadAllOrders();
    });
  }

  @override
  void dispose() {
    _inventorySearchController.dispose();
    _orderSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: Text(_titleForSection(_section)),
        actions: [
          IconButton(
            tooltip: 'Overview',
            onPressed: () => setState(() => _section = AdminSection.overview),
            icon: const Icon(Icons.space_dashboard_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.admin_panel_settings_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.adminDashboard,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Modules',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ...AdminSection.values.map((section) {
              return ListTile(
                leading: Icon(_iconForSection(section)),
                title: Text(_titleForSection(section)),
                selected: _section == section,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  setState(() => _section = section);
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onTap: () {
                Navigator.pop(context);
                _handleLogout(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionSwitcher(),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Container(
                  key: ValueKey<AdminSection>(_section),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: _buildSectionBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSwitcher() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final AdminSection section = AdminSection.values[index];
          final bool selected = _section == section;
          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            avatar: Icon(_iconForSection(section), size: 18),
            label: Text(_titleForSection(section)),
            onSelected: (_) => setState(() => _section = section),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: AdminSection.values.length,
      ),
    );
  }

  Widget _buildSectionBody() {
    switch (_section) {
      case AdminSection.overview:
        return _buildOverview();
      case AdminSection.inventory:
        return _buildInventory();
      case AdminSection.orders:
        return _buildOrders();
      case AdminSection.users:
        return _buildUsers();
      case AdminSection.analytics:
        return _buildAnalytics();
      case AdminSection.settings:
        return _buildSettings();
    }
  }

  Widget _buildOverview() {
    return Consumer2<MangoProvider, OrderProvider>(
      builder: (context, mangoProvider, orderProvider, _) {
        final int lowStock = mangoProvider.mangoes.where((mango) => mango.stock < 70).length;
        final double revenue = orderProvider.orders.fold(0.0, (sum, order) => sum + order.totalAmount);

        return ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin Control Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Track inventory and customer orders.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricCard(title: 'Total Revenue', value: '₹${revenue.toStringAsFixed(0)}', icon: Icons.currency_rupee),
                _MetricCard(title: 'Total Orders', value: '${orderProvider.orders.length}', icon: Icons.receipt_long),
                _MetricCard(title: 'Low Stock Items', value: '$lowStock', icon: Icons.warning_amber_rounded),
                _MetricCard(title: 'Available Mangos', value: '${mangoProvider.mangoes.length}', icon: Icons.shopping_bag_outlined),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => setState(() => _section = AdminSection.inventory),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Manage Inventory'),
                ),
                FilledButton.icon(
                  onPressed: () => setState(() => _section = AdminSection.orders),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Track Orders'),
                ),
                FilledButton.icon(
                  onPressed: () => setState(() => _section = AdminSection.analytics),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('View Analytics'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInventory() {
    return Consumer<MangoProvider>(
      builder: (context, mangoProvider, _) {
        final String search = _inventorySearchController.text.trim().toLowerCase();
        final List<MangoModel> filtered = mangoProvider.mangoes.where((mango) {
          return mango.name.toLowerCase().contains(search) || mango.category.toLowerCase().contains(search);
        }).toList();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inventorySearchController,
                    decoration: const InputDecoration(
                      hintText: 'Search mango by name/category',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _openAddMangoDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: mangoProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('No inventory records found'))
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final mango = filtered[index];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: ListTile(
                                leading: _MangoImageAvatar(mango: mango),
                                title: Text('${mango.name} • ${mango.category}'),
                                subtitle: Text('Stock: ${mango.stock} kg | Price: ₹${mango.price.toStringAsFixed(0)}'),
                                trailing: Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      onPressed: () => _openEditMangoDialog(mango),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      onPressed: () => _restockMango(mango.id, mangoProvider),
                                      icon: const Icon(Icons.add_box_outlined),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteMango(mango.id, mangoProvider),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrders() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final String search = _orderSearchController.text.trim().toLowerCase();
        final List filtered = orderProvider.orders.where((order) {
          return order.id.toLowerCase().contains(search) ||
              order.userId.toLowerCase().contains(search);
        }).toList();

        if (orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Separate pending and delivered orders
        final pendingOrders = filtered.where((order) => !order.status.toString().contains('delivered')).toList();
        final deliveredOrders = filtered.where((order) => order.status.toString().contains('delivered')).toList();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _orderSearchController,
                    decoration: const InputDecoration(
                      hintText: 'Search order id',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Pending Deliveries
            if (pendingOrders.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200] ?? Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.orange[700]),
                    const SizedBox(width: 10),
                    Text(
                      'Pending Delivery (${pendingOrders.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            Expanded(
              child: pendingOrders.isEmpty && deliveredOrders.isEmpty
                  ? const Center(child: Text('No orders found'))
                  : ListView.separated(
                      itemCount: pendingOrders.length + (pendingOrders.isNotEmpty && deliveredOrders.isNotEmpty ? 1 : 0) + deliveredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        // Delivered section header
                        if (pendingOrders.isNotEmpty && index == pendingOrders.length) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.green[50],
                              border: Border.all(color: Colors.green[200] ?? Colors.green),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[700]),
                                const SizedBox(width: 10),
                                Text(
                                  'Delivered (${deliveredOrders.length})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Get order from appropriate list
                        final OrderModel order;
                        if (index < pendingOrders.length) {
                          order = pendingOrders[index];
                        } else {
                          final deliveredIndex = index - pendingOrders.length - (pendingOrders.isNotEmpty && deliveredOrders.isNotEmpty ? 1 : 0);
                          order = deliveredOrders[deliveredIndex];
                        }

                        final isDelivered = order.status.toString().contains('delivered');

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          color: isDelivered ? Colors.green[50] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order ${order.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(isDelivered ? 'Delivered' : 'Pending'),
                                      backgroundColor: isDelivered ? Colors.green : Colors.orange,
                                      labelStyle: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Customer Name',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            order.customerName,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Customer ID',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            order.userId.length > 8
                                                ? order.userId.substring(0, 8)
                                                : order.userId,
                                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Delivery: ${order.shippingAddress}',
                                        style: TextStyle(color: Colors.grey[700]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.shopping_bag, color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${order.items.length} items • ₹${order.totalAmount.toStringAsFixed(0)}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                if (order.expectedDeliveryDate != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Delivery: ${order.expectedDeliveryDate!.toString().split(' ')[0]}',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ],
                                if (!isDelivered) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: () async {
                                          final selectedDate = await showDatePicker(
                                            context: context,
                                            initialDate: order.expectedDeliveryDate ?? DateTime.now().add(const Duration(days: 3)),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(const Duration(days: 30)),
                                          );
                                          
                                          if (selectedDate != null) {
                                            if (!context.mounted) return;
                                            
                                            final orderProvider = context.read<OrderProvider>();
                                            final notificationProvider = context.read<NotificationProvider>();
                                            final success = await orderProvider.setDeliveryDate(order.id, selectedDate);
                                            
                                            if (!context.mounted) return;
                                            
                                            if (success) {
                                              // Send notification to customer about delivery date
                                              notificationProvider.addNotification(
                                                'Your delivery date has been set to ${selectedDate.toString().split(' ')[0]}',
                                                orderId: order.id,
                                                title: 'Delivery Date Confirmed',
                                              );
                                            }
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: success
                                                    ? Text('Delivery date set to ${selectedDate.toString().split(' ')[0]}')
                                                    : const Text('Failed to set delivery date'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.calendar_today),
                                        label: const Text('Set Delivery Date'),
                                      ),
                                      FilledButton.icon(
                                        onPressed: () async {
                                          final orderProvider = context.read<OrderProvider>();
                                          final notificationProvider = context.read<NotificationProvider>();
                                          
                                          final success = await orderProvider.updateOrderStatus(
                                            order.id,
                                            OrderStatus.delivered,
                                          );
                                          
                                          if (context.mounted) {
                                            if (success) {
                                              // Send notification to customer
                                              notificationProvider.addNotification(
                                                'Your order has been delivered!',
                                                orderId: order.id,
                                                title: 'Order Delivered',
                                              );
                                            }
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: success
                                                    ? Text('Order ${order.id} marked as delivered')
                                                    : const Text('Failed to update order status'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.check),
                                        label: const Text('Mark as Delivered'),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsers() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        // Extract unique customer IDs from orders
        final Set<String> customerIds = {};
        for (var order in orderProvider.orders) {
          customerIds.add(order.userId);
        }
        
        final List<String> filtered = customerIds.toList();

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.blue[50],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Customers who placed orders (${filtered.length})',
                      style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No customers yet\nOrders will appear here when customers place orders',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final customerId = filtered[index];
                        // Find all orders from this customer
                        final customerOrders = orderProvider.orders
                            .where((order) => order.userId == customerId)
                            .toList();
                        final totalSpent =
                            customerOrders.fold(0.0, (sum, order) => sum + order.totalAmount);

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text('Customer'),
                            subtitle: Text(
                              '${customerOrders.length} orders • Total: ₹${totalSpent.toStringAsFixed(0)}',
                            ),
                            trailing: Chip(
                              label: Text('ID: $customerId'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return Consumer2<MangoProvider, OrderProvider>(
      builder: (context, mangoProvider, orderProvider, _) {
        final int totalOrders = orderProvider.orders.length;
        final int totalStock = mangoProvider.mangoes.fold(0, (sum, mango) => sum + mango.stock);
        final double revenue = orderProvider.orders.fold(0.0, (sum, order) => sum + order.totalAmount);

        return ListView(
          children: [
            _AnalyticsTile(
              title: 'Total Revenue',
              value: '₹${revenue.toStringAsFixed(0)}',
              progress: (revenue / 10000).clamp(0, 1).toDouble(),
            ),
            _AnalyticsTile(
              title: 'Total Orders',
              value: '$totalOrders orders',
              progress: (totalOrders / 100).clamp(0, 1).toDouble(),
            ),
            _AnalyticsTile(
              title: 'Inventory Stock',
              value: '$totalStock kg',
              progress: (totalStock / 500).clamp(0, 1).toDouble(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [Colors.blue[50] ?? Colors.blue, Colors.blue[100] ?? Colors.blue],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings, color: Colors.blue[700]),
                    const SizedBox(width: 10),
                    Text(
                      'Admin Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage application configuration',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Admin Panel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  '• Manage mango inventory\n'
                  '• Track customer orders\n'
                  '• View order analytics\n'
                  '• Upload mango images\n'
                  '• Monitor business metrics',
                  style: TextStyle(fontSize: 14, height: 1.8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _titleForSection(AdminSection section) {
    switch (section) {
      case AdminSection.overview:
        return AppStrings.adminDashboard;
      case AdminSection.inventory:
        return AppStrings.manageMangoes;
      case AdminSection.orders:
        return AppStrings.orders;
      case AdminSection.users:
        return 'User Management';
      case AdminSection.analytics:
        return 'Analytics';
      case AdminSection.settings:
        return 'Settings';
    }
  }

  IconData _iconForSection(AdminSection section) {
    switch (section) {
      case AdminSection.overview:
        return Icons.space_dashboard_outlined;
      case AdminSection.inventory:
        return Icons.inventory_2_outlined;
      case AdminSection.orders:
        return Icons.receipt_long_outlined;
      case AdminSection.users:
        return Icons.people_outline;
      case AdminSection.analytics:
        return Icons.analytics_outlined;
      case AdminSection.settings:
        return Icons.settings_outlined;
    }
  }

  Future<void> _openAddMangoDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    Uint8List? selectedImageBytes;

    final bool? created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Mango'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ImagePickerPreview(
                      imageBytes: selectedImageBytes,
                      cameraSupported: !kIsWeb,
                      onCameraTap: () async {
                        final Uint8List? bytes = await _pickImageBytes(ImageSource.camera);
                        if (bytes != null) {
                          setDialogState(() => selectedImageBytes = bytes);
                        }
                      },
                      onGalleryTap: () async {
                        final Uint8List? bytes = await _pickImageBytes(ImageSource.gallery);
                        if (bytes != null) {
                          setDialogState(() => selectedImageBytes = bytes);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock (kg)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    final String category = categoryController.text.trim();
                    final double? price = double.tryParse(priceController.text.trim());
                    final int? stock = int.tryParse(stockController.text.trim());

                    if (selectedImageBytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please capture or insert a mango image')),
                      );
                      return;
                    }

                    if (name.isEmpty || category.isEmpty || price == null || stock == null) {
                      return;
                    }

                    final newMango = MangoModel(
                      id: 'M${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      category: category,
                      stock: stock,
                      price: price,
                      description: 'Admin created mango',
                      imageUrl: '',
                      imageBytes: selectedImageBytes,
                    );

                    final success = await context.read<MangoProvider>().addMango(newMango);
                    if (mounted && success) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    stockController.dispose();

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mango added successfully')),
      );
    }
  }

  Future<void> _openEditMangoDialog(MangoModel mango) async {
    final TextEditingController nameController = TextEditingController(text: mango.name);
    final TextEditingController categoryController = TextEditingController(text: mango.category);
    final TextEditingController priceController = TextEditingController(text: mango.price.toStringAsFixed(0));
    final TextEditingController stockController = TextEditingController(text: mango.stock.toString());
    Uint8List? selectedImageBytes = mango.imageBytes;

    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Mango'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ImagePickerPreview(
                      imageBytes: selectedImageBytes,
                      cameraSupported: !kIsWeb,
                      onCameraTap: () async {
                        final Uint8List? bytes = await _pickImageBytes(ImageSource.camera);
                        if (bytes != null) {
                          setDialogState(() => selectedImageBytes = bytes);
                        }
                      },
                      onGalleryTap: () async {
                        final Uint8List? bytes = await _pickImageBytes(ImageSource.gallery);
                        if (bytes != null) {
                          setDialogState(() => selectedImageBytes = bytes);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock (kg)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    final String category = categoryController.text.trim();
                    final double? price = double.tryParse(priceController.text.trim());
                    final int? stock = int.tryParse(stockController.text.trim());

                    if (name.isEmpty || category.isEmpty || price == null || stock == null) {
                      return;
                    }

                    final updatedMango = mango.copyWith(
                      name: name,
                      category: category,
                      price: price,
                      stock: stock,
                      imageBytes: selectedImageBytes,
                    );

                    final success = await context.read<MangoProvider>().updateMango(updatedMango);
                    if (mounted && success) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    stockController.dispose();

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mango updated successfully')),
      );
    }
  }

  void _restockMango(String id, MangoProvider provider) async {
    final mango = provider.mangoes.firstWhere((m) => m.id == id);
    final updatedMango = mango.copyWith(stock: mango.stock + 10);
    await provider.updateMango(updatedMango);
  }

  void _deleteMango(String id, MangoProvider provider) async {
    await provider.deleteMango(id);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from admin dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<Uint8List?> _pickImageBytes(ImageSource source) async {
    final ImageSource effectiveSource = kIsWeb && source == ImageSource.camera
        ? ImageSource.gallery
        : source;

    if (kIsWeb && source == ImageSource.camera && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera capture is not supported on web. Opening insert picker.')),
      );
    }

    try {
      final XFile? file = kIsWeb
          ? await _imagePicker.pickImage(source: effectiveSource)
          : await _imagePicker.pickImage(source: effectiveSource, imageQuality: 80);

      if (file == null) {
        return null;
      }

      return await file.readAsBytes();
    } on MissingPluginException {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image picker not initialized. Please fully restart the app and try again.')),
      );
      return null;
    } on PlatformException catch (error) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image access failed: ${error.message ?? error.code}')),
      );
      return null;
    } catch (error) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selection failed. Please try again. ($error)')),
      );
      return null;
    }
  }
}

class _MangoImageAvatar extends StatelessWidget {
  const _MangoImageAvatar({required this.mango});

  final MangoModel mango;

  @override
  Widget build(BuildContext context) {
    if (mango.imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.memory(
          mango.imageBytes!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }

    if (mango.imageUrl.isNotEmpty && mango.imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          mango.imageUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            child: Text(mango.name.isNotEmpty ? mango.name[0] : 'M'),
          ),
        ),
      );
    }

    return CircleAvatar(
      child: Text(mango.name.isNotEmpty ? mango.name[0] : 'M'),
    );
  }
}

class _ImagePickerPreview extends StatelessWidget {
  const _ImagePickerPreview({
    required this.imageBytes,
    required this.cameraSupported,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final Uint8List? imageBytes;
  final bool cameraSupported;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: imageBytes == null
              ? const Center(child: Text('No image selected'))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.memory(imageBytes!, fit: BoxFit.cover),
                ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: cameraSupported ? onCameraTap : null,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Camera'),
            ),
            OutlinedButton.icon(
              onPressed: onGalleryTap,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Insert'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 22),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsTile extends StatelessWidget {
  const _AnalyticsTile({required this.title, required this.value, required this.progress});

  final String title;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(value),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
          ],
        ),
      ),
    );
  }
}
