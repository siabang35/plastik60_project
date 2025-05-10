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

    // Delay sedikit untuk memastikan widget sudah terpasang sebelum navigasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      print("Mulai navigasi dari splash screen");
      await Future.delayed(const Duration(seconds: 2));

      // Metode 1: Menggunakan Provider (jika StorageService sudah terdaftar di Provider)
      try {
        final storageService = Provider.of<StorageService>(
          context,
          listen: false,
        );
        final authService = Provider.of<AuthService>(context, listen: false);

        print("Berhasil mendapatkan services dari Provider");

        final onboardingCompleted =
            await storageService.getBool(AppConstants.onboardingKey) ?? false;

        print("Onboarding completed: $onboardingCompleted");

        if (!onboardingCompleted) {
          if (mounted) {
            print("Navigasi ke onboarding");
            Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
          }
          return;
        }

        final isAuthenticated = await authService.checkAuth();
        print("Is authenticated: $isAuthenticated");

        if (mounted) {
          if (isAuthenticated) {
            print("Navigasi ke home");
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else {
            print("Navigasi ke login");
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        }
      } catch (providerError) {
        // Metode 2: Jika Provider gagal, gunakan dependency injection langsung
        print("Error dengan Provider: $providerError");
        print("Mencoba dengan dependency injection langsung");

        final storageService = await StorageService().init();
        final authService = AuthService(storageService);

        final onboardingCompleted =
            await storageService.getBool(AppConstants.onboardingKey) ?? false;

        print("Onboarding completed (direct): $onboardingCompleted");

        if (!onboardingCompleted) {
          if (mounted) {
            print("Navigasi ke onboarding (direct)");
            Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
          }
          return;
        }

        final isAuthenticated = await authService.checkAuth();
        print("Is authenticated (direct): $isAuthenticated");

        if (mounted) {
          if (isAuthenticated) {
            print("Navigasi ke home (direct)");
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else {
            print("Navigasi ke login (direct)");
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        }
      }
    } catch (e) {
      print("Error dalam _checkAuthAndNavigate: $e");
      // Fallback navigation jika terjadi error
      if (mounted) {
        print("Navigasi fallback ke login karena error");
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
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
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading logo: $error");
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.white24,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
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
