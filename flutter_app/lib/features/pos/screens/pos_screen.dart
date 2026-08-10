import 'package:flutter/material.dart';

import '../../layout/screens/app_shell.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: const Center(
        child: Text(
          'POS',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}