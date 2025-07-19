import 'package:flutter/material.dart';
import '/common/common_layout.dart';

class SalesRevenuePage extends StatelessWidget {
  const SalesRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(
        child: Text('Sales Revenue Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
