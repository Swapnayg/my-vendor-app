import 'package:flutter/material.dart';
import '../common/common_layout.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(
        child: Text(
          'Reports Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
