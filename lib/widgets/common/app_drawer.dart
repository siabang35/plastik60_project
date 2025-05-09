import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user?.profileImage != null
                          ? NetworkImage(user!.profileImage!)
                          : null,
                  child:
                      user?.profileImage == null
                          ? const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.blue,
                          )
                          : null,
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'Guest',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  user?.email ?? 'Sign in to your account',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.productList);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.cart);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.orderHistory);
              Navigator.of(context).pop();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Us'),
            onTap: () {
              // Navigate to about page
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text('Contact Us'),
            onTap: () {
              // Navigate to contact page
              Navigator.of(context).pop();
            },
          ),
          const Divider(),
          if (authService.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.of(context).pop();
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
            ),
        ],
      ),
    );
  }
}
