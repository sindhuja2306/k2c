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

  // Responsive breakpoints
  bool get _isMobile => MediaQuery.of(context).size.width < 600;
  bool get _isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;
  bool get _isDesktop => MediaQuery.of(context).size.width >= 900;
  
  int get _gridColumns {
    if (_isDesktop) return 4;
    if (_isTablet) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          _titleForSection(_section),
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (!_isMobile)
            IconButton(
              tooltip: 'Dashboard',
              onPressed: () => setState(() => _section = AdminSection.overview),
              icon: const Icon(Icons.dashboard_rounded),
            ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(colorScheme),
      body: Column(
        children: [
          // Modern gradient header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green[600]!,
                  Colors.green[400]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _isMobile ? 16 : 24,
                  16,
                  _isMobile ? 16 : 24,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _iconForSection(_section),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'K2C Admin Panel',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _titleForSection(_section),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionSwitcher(),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey<AdminSection>(_section),
                child: _buildSectionBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[600]!, Colors.green[400]!],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'K2C Control Center',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...AdminSection.values.map((section) {
              final bool isSelected = _section == section;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListTile(
                  leading: Icon(
                    _iconForSection(section),
                    color: isSelected ? Colors.green[600] : Colors.grey[600],
                  ),
                  title: Text(
                    _titleForSection(section),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.green[600] : Colors.grey[800],
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Colors.green[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    setState(() => _section = section);
                    Navigator.pop(context);
                  },
                ),
              );
            }),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSwitcher() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _isMobile ? 0 : 4),
        itemBuilder: (context, index) {
          final AdminSection section = AdminSection.values[index];
          final bool selected = _section == section;
          return Material(
            color: selected ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => setState(() => _section = section),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForSection(section),
                      size: 20,
                      color: selected ? Colors.green[600] : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _titleForSection(section),
                      style: TextStyle(
                        color: selected ? Colors.green[600] : Colors.white,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        final int pendingOrders = orderProvider.orders
            .where((order) => !order.status.toString().contains('delivered'))
            .length;
        final int totalItems = mangoProvider.mangoes.length;

        return Container(
          color: Colors.grey[50],
          child: ListView(
            padding: EdgeInsets.all(_isMobile ? 16 : 24),
            children: [
              // Statistics Grid
              GridView.count(
                crossAxisCount: _gridColumns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: _isMobile ? 1.1 : 1.2,
                children: [
                  _ModernMetricCard(
                    title: 'Total Revenue',
                    value: '₹${revenue.toStringAsFixed(0)}',
                    icon: Icons.currency_rupee_rounded,
                    gradient: [Colors.blue[400]!, Colors.blue[600]!],
                    trend: '+12.5%',
                  ),
                  _ModernMetricCard(
                    title: 'Total Orders',
                    value: '${orderProvider.orders.length}',
                    icon: Icons.receipt_long_rounded,
                    gradient: [Colors.purple[400]!, Colors.purple[600]!],
                    subtitle: '$pendingOrders pending',
                  ),
                  _ModernMetricCard(
                    title: 'Low Stock Alert',
                    value: '$lowStock',
                    icon: Icons.warning_amber_rounded,
                    gradient: [Colors.orange[400]!, Colors.orange[600]!],
                    subtitle: lowStock > 0 ? 'Need restock' : 'All good',
                  ),
                  _ModernMetricCard(
                    title: 'Mango Varieties',
                    value: '$totalItems',
                    icon: Icons.inventory_2_rounded,
                    gradient: [Colors.green[400]!, Colors.green[600]!],
                    subtitle: 'In inventory',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Quick Actions Section
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.green[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: _isMobile ? 1 : (_isTablet ? 2 : 3),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: _isMobile ? 3.5 : 3,
                children: [
                  _QuickActionCard(
                    title: 'Manage Inventory',
                    subtitle: 'Add or update mango products',
                    icon: Icons.inventory_2_rounded,
                    color: Colors.green,
                    onTap: () => setState(() => _section = AdminSection.inventory),
                  ),
                  _QuickActionCard(
                    title: 'Track Orders',
                    subtitle: 'View and manage customer orders',
                    icon: Icons.local_shipping_rounded,
                    color: Colors.blue,
                    onTap: () => setState(() => _section = AdminSection.orders),
                  ),
                  _QuickActionCard(
                    title: 'View Analytics',
                    subtitle: 'Business insights and metrics',
                    icon: Icons.analytics_rounded,
                    color: Colors.purple,
                    onTap: () => setState(() => _section = AdminSection.analytics),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Recent Activity
              Row(
                children: [
                  Icon(Icons.history_rounded, color: Colors.green[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ActivityItem(
                      icon: Icons.shopping_cart_rounded,
                      title: 'New Order Received',
                      subtitle: '${orderProvider.orders.length} total orders',
                      time: 'Just now',
                      color: Colors.green,
                    ),
                    const Divider(height: 24),
                    _ActivityItem(
                      icon: Icons.inventory_rounded,
                      title: 'Inventory Updated',
                      subtitle: '$totalItems varieties available',
                      time: '2 hours ago',
                      color: Colors.blue,
                    ),
                    if (lowStock > 0) ...[
                      const Divider(height: 24),
                      _ActivityItem(
                        icon: Icons.warning_rounded,
                        title: 'Low Stock Alert',
                        subtitle: '$lowStock items need restocking',
                        time: 'Today',
                        color: Colors.orange,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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

        return Container(
          color: Colors.grey[50],
          child: Column(
            children: [
              // Search and Add Bar
              Container(
                padding: EdgeInsets.all(_isMobile ? 16 : 24),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _inventorySearchController,
                          decoration: InputDecoration(
                            hintText: 'Search mangoes...',
                            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _openAddMangoDialog,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: EdgeInsets.symmetric(
                          horizontal: _isMobile ? 16 : 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(_isMobile ? 'Add' : 'Add Mango'),
                    ),
                  ],
                ),
              ),
              // Mango List
              Expanded(
                child: mangoProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  search.isEmpty ? 'No mangoes in inventory' : 'No matching mangoes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(_isMobile ? 16 : 24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _isMobile ? 1 : (_isTablet ? 2 : 3),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: _isMobile ? 1.35 : (_isTablet ? 1.45 : 1.55),
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final mango = filtered[index];
                              final bool isLowStock = mango.stock < 70;
                              
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _MangoImageAvatar(mango: mango),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  mango.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[50],
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    mango.category,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green[700],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isLowStock)
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.warning_rounded,
                                                color: Colors.orange[600],
                                                size: 20,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Stock',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${mango.stock} kg',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: isLowStock ? Colors.orange[600] : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Price',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '₹${mango.price.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () => _openEditMangoDialog(mango),
                                            icon: Icon(Icons.edit_rounded, color: Colors.blue[600]),
                                            tooltip: 'Edit',
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.blue[50],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => _restockMango(mango.id, mangoProvider),
                                            icon: Icon(Icons.add_box_rounded, color: Colors.green[600]),
                                            tooltip: 'Restock +10kg',
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.green[50],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => _deleteMango(mango.id, mangoProvider),
                                            icon: Icon(Icons.delete_rounded, color: Colors.red[600]),
                                            tooltip: 'Delete',
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.red[50],
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
              ),
            ],
          ),
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
        final int deliveredOrders = orderProvider.orders
            .where((order) => order.status.toString().contains('delivered'))
            .length;
        final double avgOrderValue = totalOrders > 0 ? revenue / totalOrders : 0;

        return Container(
          color: Colors.grey[50],
          child: ListView(
            padding: EdgeInsets.all(_isMobile ? 16 : 24),
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: Colors.green[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Business Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _EnhancedAnalyticsTile(
                title: 'Total Revenue',
                value: '₹${revenue.toStringAsFixed(0)}',
                progress: (revenue / 100000).clamp(0, 1).toDouble(),
                icon: Icons.currency_rupee_rounded,
                gradient: [Colors.green[400]!, Colors.green[600]!],
                targetLabel: 'Target: ₹1,00,000',
              ),
              _EnhancedAnalyticsTile(
                title: 'Order Completion Rate',
                value: totalOrders > 0 
                    ? '${((deliveredOrders / totalOrders) * 100).toStringAsFixed(1)}%'
                    : '0%',
                progress: totalOrders > 0 ? deliveredOrders / totalOrders : 0,
                icon: Icons.check_circle_rounded,
                gradient: [Colors.blue[400]!, Colors.blue[600]!],
                targetLabel: '$deliveredOrders of $totalOrders orders',
              ),
              _EnhancedAnalyticsTile(
                title: 'Average Order Value',
                value: '₹${avgOrderValue.toStringAsFixed(0)}',
                progress: (avgOrderValue / 1000).clamp(0, 1).toDouble(),
                icon: Icons.attach_money_rounded,
                gradient: [Colors.purple[400]!, Colors.purple[600]!],
                targetLabel: 'Per customer order',
              ),
              _EnhancedAnalyticsTile(
                title: 'Inventory Stock',
                value: '$totalStock kg',
                progress: (totalStock / 1000).clamp(0, 1).toDouble(),
                icon: Icons.inventory_2_rounded,
                gradient: [Colors.orange[400]!, Colors.orange[600]!],
                targetLabel: 'Total available',
              ),
              const SizedBox(height: 16),
              
              // Additional insights
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights_rounded, color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Key Insights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InsightRow(
                      icon: Icons.shopping_cart_rounded,
                      label: 'Total Orders',
                      value: totalOrders.toString(),
                      color: Colors.blue,
                    ),
                    const Divider(height: 20),
                    _InsightRow(
                      icon: Icons.local_shipping_rounded,
                      label: 'Delivered Orders',
                      value: deliveredOrders.toString(),
                      color: Colors.green,
                    ),
                    const Divider(height: 20),
                    _InsightRow(
                      icon: Icons.pending_actions_rounded,
                      label: 'Pending Delivery',
                      value: (totalOrders - deliveredOrders).toString(),
                      color: Colors.orange,
                    ),
                    const Divider(height: 20),
                    _InsightRow(
                      icon: Icons.category_rounded,
                      label: 'Mango Varieties',
                      value: mangoProvider.mangoes.length.toString(),
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettings() {
    return Container(
      color: Colors.grey[50],
      child: ListView(
        padding: EdgeInsets.all(_isMobile ? 16 : 24),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[400]!, Colors.blue[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your admin panel configuration',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // About Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'About Admin Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FeatureItem(
                  icon: Icons.inventory_2_rounded,
                  title: 'Inventory Management',
                  description: 'Add, edit, and manage mango products with images',
                ),
                _FeatureItem(
                  icon: Icons.shopping_cart_rounded,
                  title: 'Order Tracking',
                  description: 'Monitor and manage customer orders in real-time',
                ),
                _FeatureItem(
                  icon: Icons.analytics_rounded,
                  title: 'Business Analytics',
                  description: 'View revenue, sales trends, and performance metrics',
                ),
                _FeatureItem(
                  icon: Icons.people_rounded,
                  title: 'Customer Management',
                  description: 'Track customer orders and purchase history',
                ),
                _FeatureItem(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  description: 'Send updates to customers about their orders',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // App Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                const Text(
                  'K2C Mango Delivery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin Panel v1.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2024 K2C - Kissan to Customer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        return Icons.dashboard_rounded;
      case AdminSection.inventory:
        return Icons.inventory_2_rounded;
      case AdminSection.orders:
        return Icons.receipt_long_rounded;
      case AdminSection.users:
        return Icons.people_rounded;
      case AdminSection.analytics:
        return Icons.analytics_rounded;
      case AdminSection.settings:
        return Icons.settings_rounded;
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

class _EnhancedAnalyticsTile extends StatelessWidget {
  const _EnhancedAnalyticsTile({
    required this.title,
    required this.value,
    required this.progress,
    required this.icon,
    required this.gradient,
    this.targetLabel,
  });

  final String title;
  final String value;
  final double progress;
  final IconData icon;
  final List<Color> gradient;
  final String? targetLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          if (targetLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              targetLabel!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color[600], size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color[600],
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernMetricCard extends StatelessWidget {
  const _ModernMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.subtitle,
    this.trend,
  });

  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final String? subtitle;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final MaterialColor color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color[600], size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color[600], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
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
