import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../layout/screens/app_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Welcome to StoreManager',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: 300,
                  child: _DashboardCard(
                    icon: Icons.category,
                    title: 'Categories',
                    subtitle: 'Manage categories',
                    buttonText: 'Open Categories',
                    onPressed: () {
                      context.go('/categories');
                    },
                  ),
                ),

                SizedBox(
                  width: 300,
                  child: _DashboardCard(
                    icon: Icons.inventory_2,
                    title: 'Products',
                    subtitle: 'Manage Products',
                    buttonText: 'Open Products',
                    onPressed: () {
                      context.go('/products');
                    },
                  ),
                ),

                SizedBox(
                  width: 300,
                  child: _DashboardCard(
                    icon: Icons.point_of_sale,
                    title: 'Point of Sale',
                    subtitle: 'Coming in later slices',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onPressed;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 42),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(subtitle),

            if (buttonText != null) ...[
              const SizedBox(height: 20),

              ElevatedButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
