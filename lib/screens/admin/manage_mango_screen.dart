import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class ManageMangoScreen extends StatelessWidget {
  const ManageMangoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboard(
      initialSection: AdminSection.inventory,
    );
  }
}
