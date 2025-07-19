import 'package:flutter/material.dart';
import '/common/common_layout.dart';

class TopproductsPage extends StatelessWidget {
  const TopproductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(
        child: Text('Top Products Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
