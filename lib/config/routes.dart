import 'package:flutter/material.dart';
import 'package:plastik60_app/screens/splash/splash_screen.dart';
import 'package:plastik60_app/screens/onboarding/onboarding_screen.dart';
import 'package:plastik60_app/screens/auth/login_screen.dart';
import 'package:plastik60_app/screens/auth/register_screen.dart';
import 'package:plastik60_app/screens/auth/forgot_password_screen.dart';
import 'package:plastik60_app/screens/home/home_screen.dart';
import 'package:plastik60_app/screens/product/product_list_screen.dart';
import 'package:plastik60_app/screens/product/product_detail_screen.dart';
import 'package:plastik60_app/screens/cart/cart_screen.dart';
import 'package:plastik60_app/screens/checkout/checkout_screen.dart';
import 'package:plastik60_app/screens/order/order_history_screen.dart';
import 'package:plastik60_app/screens/order/order_detail_screen.dart';
import 'package:plastik60_app/screens/profile/profile_screen.dart';
import 'package:plastik60_app/screens/settings/settings_screen.dart';
import 'package:plastik60_app/services/auth_service.dart';

class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetail = '/product';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/orders';
  static const String orderDetail = '/order';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final name = routeSettings.name;

    switch (name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        final authService = routeSettings.arguments as AuthService;
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(authService: authService),
        );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case productList:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => ProductListScreen(
                categoryId: args?['categoryId'],
                categoryName: args?['categoryName'],
                isSearch: args?['isSearch'] ?? false,
                searchQuery: args?['searchQuery'],
              ),
        );
      case productDetail:
        final productId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case orderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case orderDetail:
        final orderId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: orderId),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.settings: // gunakan konstanta class
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('No route defined for $name')),
              ),
        );
    }
  }
}
