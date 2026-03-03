class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.mangoselling.com';
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // Mango Endpoints
  static const String mangoes = '/mangoes';
  static const String mangoDetails = '/mangoes/';
  static const String addMango = '/mangoes/add';
  static const String updateMango = '/mangoes/update';
  static const String deleteMango = '/mangoes/delete';
  
  // Cart Endpoints
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String removeFromCart = '/cart/remove';
  static const String updateCartItem = '/cart/update';
  
  // Order Endpoints
  static const String orders = '/orders';
  static const String placeOrder = '/orders/place';
  static const String orderDetails = '/orders/';
  static const String cancelOrder = '/orders/cancel';
  
  // User Endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update';
}
