import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/config/theme.dart';
import 'package:plastik60_app/screens/splash/splash_screen.dart';

class PlastikApp extends StatelessWidget {
  const PlastikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plastik60',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light theme
      home: SplashScreen(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      navigatorKey: AppRoutes.navigatorKey,
    );
  }
}
