import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/services/location_service.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isDetectingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _isDetectingLocation = true;
    });

    try {
      print('Starting location detection...');
      
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
        setState(() {
          _addressController.text = address;
        });
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Location detected successfully!',
          );
        }
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Could not detect address. Please enter manually.',
            isError: true,
          );
        }
      }
    } catch (e) {
      print('Error in _detectCurrentLocation: $e');
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      setState(() {
        _isDetectingLocation = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      Helpers.showLoadingDialog(context);
      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      
      if (mounted) {
        Helpers.hideLoadingDialog(context);
        
        if (success) {
          Helpers.showSnackBar(context, 'Registration successful!');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Helpers.showSnackBar(
            context,
            authProvider.errorMessage ?? 'Registration failed',
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
        title: const Text(AppStrings.register),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: _isDetectingLocation
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.my_location),
                            tooltip: 'Detect current location',
                            onPressed: _detectCurrentLocation,
                          ),
                  ),
                  maxLines: 2,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.confirmPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleRegister,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(AppStrings.register, style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.alreadyHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(AppStrings.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
