import 'package:flutter/material.dart';
import 'package:store_manager/features/layout/widgets/app_drawer.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StoreManager')),

      drawer: const AppDrawer(),

      body: child,
    );
  }
}
