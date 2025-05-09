import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/user.dart';
import 'package:plastik60_app/services/auth_service.dart';
import 'package:plastik60_app/services/storage_service.dart';
import 'package:plastik60_app/widgets/common/custom_button.dart';
import 'package:plastik60_app/widgets/common/custom_text_field.dart';
import 'package:plastik60_app/utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  User? _user;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isUpdating = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(StorageService());
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Check if user is authenticated
      final isAuthenticated = await _authService.checkAuth();
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Get current user from auth service
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      setState(() {
        _user = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _authService.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
      );

      await _loadUserProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final formKey = GlobalKey<FormState>();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Change Password'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextField(
                          controller: currentPasswordController,
                          labelText: 'Current Password',
                          obscureText: obscureCurrentPassword,
                          validator:
                              (value) => Validators.validateRequired(
                                value,
                                'Current password',
                              ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureCurrentPassword =
                                    !obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: newPasswordController,
                          labelText: 'New Password',
                          obscureText: obscureNewPassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureNewPassword = !obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: confirmPasswordController,
                          labelText: 'Confirm New Password',
                          obscureText: obscureConfirmPassword,
                          validator:
                              (value) => Validators.validateConfirmPassword(
                                value,
                                newPasswordController.text,
                              ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          await _changePassword(
                            currentPasswordController.text,
                            newPasswordController.text,
                            confirmPasswordController.text,
                          );
                        }
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    setState(() {
      _isChangingPassword = true;
    });

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _authService.logout();

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to logout: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(child: Text('Unable to load user profile'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Update Profile',
                  isLoading: _isUpdating,
                  onPressed: _updateProfile,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Change Password',
                  isLoading: _isChangingPassword,
                  onPressed: _showChangePasswordDialog,
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Logout',
                  onPressed: _logout,
                  backgroundColor: Colors.red,
                  icon: Icons.logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
