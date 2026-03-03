import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/customer/main_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../screens/customer/notifications_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_mango_screen.dart';
import '../screens/admin/orders_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
  static const String adminManageMango = '/admin/manage-mango';
  static const String adminOrders = '/admin/orders';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case adminManageMango:
        return MaterialPageRoute(builder: (_) => const ManageMangoScreen());
      case adminOrders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
