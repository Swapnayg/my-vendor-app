import 'package:flutter/material.dart';
import '/common/common_layout.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(
        child: Text('Inventory Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
