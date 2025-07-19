import 'package:flutter/material.dart';
import '/common/common_layout.dart';

class InventoryManagementPage extends StatelessWidget {
  const InventoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(
        child: Text('Product Management Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
