import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:plastik60_app/app.dart';
import 'package:plastik60_app/services/auth_service.dart';
import 'package:plastik60_app/services/cart_service.dart';
import 'package:plastik60_app/services/order_service.dart';
import 'package:plastik60_app/services/product_service.dart';
import 'package:plastik60_app/services/storage_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Inisialisasi storage dan services terlebih dahulu.
    final storageService = await StorageService().init();
    final authService = AuthService(storageService);
    final productService = ProductService();
    final cartService = CartService(storageService);
    final orderService = OrderService();

    await authService.checkAuth();

    // Build the widget tree dengan Provider seperti di main.dart
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => authService),
          ChangeNotifierProvider(create: (_) => productService),
          ChangeNotifierProvider(create: (_) => cartService),
          ChangeNotifierProvider(create: (_) => orderService),
        ],
        child: const MaterialApp(home: PlastikApp()),
      ),
    );

    // Pastikan text '0' muncul
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap icon +
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Pastikan counter bertambah
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
