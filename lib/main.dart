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

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services that need async init
  final storageService = await StorageService().init();
  final authService = AuthService(storageService);
  final cartService = CartService(storageService);

  // Optional: check if user is logged in
  await authService.checkAuth();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<CartService>.value(value: cartService),
        ChangeNotifierProvider<ProductService>(create: (_) => ProductService()),
        ChangeNotifierProvider<OrderService>(create: (_) => OrderService()),
      ],
      child: const PlastikApp(),
    ),
  );
}
