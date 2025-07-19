import 'package:flutter/material.dart';
import '../common/common_layout.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: const Center(
        child: Text('Notifications Page', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
