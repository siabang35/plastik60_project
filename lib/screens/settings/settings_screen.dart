import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/config/theme.dart';
import 'package:plastik60_app/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isDarkMode = await _storageService.getBool('dark_mode') ?? false;
    final notificationsEnabled =
        await _storageService.getBool('notifications_enabled') ?? true;
    final selectedLanguage =
        await _storageService.getString('language') ?? 'en';

    setState(() {
      _isDarkMode = isDarkMode;
      _notificationsEnabled = notificationsEnabled;
      _selectedLanguage = selectedLanguage;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _storageService.setBool('dark_mode', value);
    setState(() {
      _isDarkMode = value;
    });

    // This would typically update the app's theme
    // In a real app, you'd use a state management solution like Provider
  }

  Future<void> _toggleNotifications(bool value) async {
    await _storageService.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _setLanguage(String value) async {
    await _storageService.setString('language', value);
    setState(() {
      _selectedLanguage = value;
    });

    // This would typically update the app's locale
    // In a real app, you'd use a localization package
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),

          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text(
              'Receive notifications about orders and promotions',
            ),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),

          _buildSectionHeader('Language'),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _selectedLanguage,
            onChanged: (value) => _setLanguage(value!),
          ),
          RadioListTile<String>(
            title: const Text('Bahasa Indonesia'),
            value: 'id',
            groupValue: _selectedLanguage,
            onChanged: (value) => _setLanguage(value!),
          ),
          const Divider(),

          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.orderHistory);
            },
          ),
          const Divider(),

          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Plastik60'),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            onTap: () {
              // Navigate to terms and conditions
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'App Version: 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AboutDialog(
            applicationName: 'Plastik60',
            applicationVersion: '1.0.0',
            applicationIcon: Image.asset(
              'assets/images/logo.png',
              width: 50,
              height: 50,
            ),
            children: const [
              SizedBox(height: 16),
              Text(
                'Plastik60 is your one-stop shop for high-quality plastic products. '
                'We offer a wide range of plastic items for household, industrial, '
                'and commercial use.',
              ),
              SizedBox(height: 16),
              Text('© 2023 Plastik60. All rights reserved.'),
            ],
          ),
    );
  }
}
