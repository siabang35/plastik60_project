import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plastik60_app/config/constants.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/services/auth_service.dart';
import 'package:plastik60_app/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final storageService = Provider.of<StorageService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    // Check if onboarding is completed
    final onboardingCompleted =
        await storageService.getBool(AppConstants.onboardingKey) ?? false;

    if (!onboardingCompleted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      return;
    }

    // Check if user is authenticated
    final isAuthenticated = await authService.checkAuth();

    if (isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(scale: _scaleAnimation, child: child),
                );
              },
              child: Image.asset(
                AppConstants.logoWhitePath,
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(opacity: _fadeAnimation, child: child);
              },
              child: const Text(
                'Plastik60',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(opacity: _fadeAnimation, child: child);
              },
              child: const Text(
                'Your Plastic Packaging Solution',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
