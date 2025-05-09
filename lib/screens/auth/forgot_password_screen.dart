import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/services/auth_service.dart';
import 'package:plastik60_app/services/storage_service.dart';
import 'package:plastik60_app/utils/validators.dart';
import 'package:plastik60_app/widgets/common/custom_button.dart';
import 'package:plastik60_app/widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _resetSent = false;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    final storageService = StorageService(); // inisialisasi StorageService
    _authService = AuthService(storageService);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _authService.forgotPassword(
          _emailController.text,
        );

        if (mounted && success) {
          setState(() {
            _resetSent = true;
          });
        } else {
          _showError(_authService.error ?? 'Failed to send reset link');
        }
      } catch (e) {
        _showError('Unexpected error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _resetSent ? _buildSuccessView() : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Image.asset('assets/images/forgot_password.png', height: 150),
          const SizedBox(height: 30),
          const Text(
            'Forgot Password',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 30),
          CustomButton(
            text: 'Send Reset Link',
            isLoading: _isLoading,
            onPressed: _resetPassword,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Remember your password?'),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
        const SizedBox(height: 30),
        const Text(
          'Reset Link Sent',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Please check your email and follow the instructions to reset your password.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        CustomButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
        ),
      ],
    );
  }
}
