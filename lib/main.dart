import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:plastik60_app/app.dart';
import 'package:plastik60_app/services/auth_service.dart';
import 'package:plastik60_app/services/cart_service.dart';
import 'package:plastik60_app/services/product_service.dart';
import 'package:plastik60_app/services/order_service.dart';
import 'package:plastik60_app/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final storageService = await StorageService().init();
  final authService = AuthService(storageService);
  final productService = ProductService();
  final cartService = CartService(storageService);
  final orderService = OrderService();

  // Check if user is already logged in
  await authService.checkAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => productService),
        ChangeNotifierProvider(create: (_) => cartService),
        ChangeNotifierProvider(create: (_) => orderService),
      ],
      child: const PlastikApp(),
    ),
  );
}
