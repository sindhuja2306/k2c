import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/helpers.dart';
import '../../core/services/location_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import 'main_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDetectingLocation = false;

  Future<void> _updateLocationAddress() async {
    setState(() {
      _isDetectingLocation = true;
    });

    try {
      print('Starting location detection from profile...');
      
      // Check if location service is enabled
      bool serviceEnabled = await LocationService.isLocationServiceEnabled();
      print('Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Location services are disabled. Please enable them in your browser.',
            isError: true,
          );
        }
        setState(() {
          _isDetectingLocation = false;
        });
        return;
      }

      // Check and request permission
      bool hasPermission = await LocationService.checkAndRequestPermission();
      print('Has permission: $hasPermission');
      
      if (!hasPermission) {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Location permission denied. Please allow location access.',
            isError: true,
          );
        }
        setState(() {
          _isDetectingLocation = false;
        });
        return;
      }

      // Get current location address
      print('Getting current location address...');
      String? address = await LocationService.getCurrentLocationAddress();
      print('Address received: $address');

      if (address != null && address.isNotEmpty) {
        if (mounted) {
          // Show dialog to confirm address update
            final message = 'Update your address to:\n\n$address';
              
          final confirm = await Helpers.showConfirmDialog(
            context,
            title: 'Update Address',
            message: message,
          );

          if (confirm) {
            // Here you would typically call an API to update the user's address
            // For now, we'll just show a success message
            Helpers.showSnackBar(
              context,
              'Address updated successfully!',
            );
            // TODO: Update user address in provider/service
            // await context.read<AuthProvider>().updateAddress(address);
          }
        }
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Could not detect location. Please try again.',
            isError: true,
          );
        }
      }
    } catch (e) {
      print('Error in _updateLocationAddress: $e');
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('Not logged in'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (user.isAdmin) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Text(
                            '👑 ADMIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Body content
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(Icons.phone, 'Phone Number', user.phone),
                      const SizedBox(height: 12),
                      _buildLocationCard(user.address),
                      const SizedBox(height: 24),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user.isCustomer)
                        _buildActionCard(
                          context,
                          icon: Icons.shopping_bag,
                          title: 'My Orders',
                          subtitle: 'Track your orders',
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to orders tab (index 2)
                            final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                            if (mainScreenState != null) {
                              mainScreenState.changeTab(2);
                            }
                          },
                        ),
                      if (user.isAdmin) ...[
                        const SizedBox(height: 12),
                        _buildActionCard(
                          context,
                          icon: Icons.dashboard,
                          title: 'Admin Dashboard',
                          subtitle: 'Manage your store',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pushNamed(context, '/admin');
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'App preferences',
                        color: Colors.grey,
                        onTap: () {
                          Helpers.showSnackBar(context, 'Settings coming soon');
                        },
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Logout',
                        color: Colors.red,
                        onPressed: () async {
                          final confirm = await Helpers.showConfirmDialog(
                            context,
                            title: 'Logout',
                            message: 'Are you sure you want to logout?',
                          );

                          if (confirm && context.mounted) {
                            await authProvider.logout();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: Colors.grey[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String address) {
    return InkWell(
      onTap: _isDetectingLocation ? null : _updateLocationAddress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_on,
                size: 24,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 10,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Tap to update',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_isDetectingLocation)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.edit_location_alt,
                color: Colors.grey[400],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
