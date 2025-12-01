import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar'),
      ),
      body: const Center(
        child: Text('Sozlamalar bu yerdan boshqariladi.'),
      ),
    );
  }
}
