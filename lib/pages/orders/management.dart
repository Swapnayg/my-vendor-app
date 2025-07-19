import 'package:flutter/material.dart';
import '/common/common_layout.dart';

class OrderManagementPage extends StatelessWidget {
  const OrderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(
        child: Text('Order Management Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
