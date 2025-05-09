import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plastik60_app/config/constants.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    await storageService.setBool(AppConstants.onboardingKey, true);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: AppConstants.onboardingTitles.length,
                    itemBuilder: (context, index) {
                      return _buildPage(
                        title: AppConstants.onboardingTitles[index],
                        description: AppConstants.onboardingDescriptions[index],
                        image: AppConstants.onboardingImages[index],
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          AppConstants.onboardingTitles.length,
                          (index) => _buildDot(index),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _currentPage > 0
                                ? TextButton(
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[700],
                                  ),
                                  child: const Text('Previous'),
                                )
                                : const SizedBox(
                                  width: 80,
                                ), // Placeholder for balance
                            _currentPage <
                                    AppConstants.onboardingTitles.length - 1
                                ? ElevatedButton(
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Next'),
                                )
                                : ElevatedButton(
                                  onPressed: _completeOnboarding,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Get Started'),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required String image,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: image,
            child: Image.asset(image, height: 250, fit: BoxFit.contain),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
