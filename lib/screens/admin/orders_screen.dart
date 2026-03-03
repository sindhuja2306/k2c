import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboard(
      initialSection: AdminSection.orders,
    );
  }
}
