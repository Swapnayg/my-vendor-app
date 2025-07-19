import 'package:flutter/material.dart';
import '../common/common_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: const Center(
        child: Text('Settings Page', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
