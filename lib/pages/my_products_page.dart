import 'package:flutter/material.dart';
import '../common/common_layout.dart';

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: const Center(
        child: Text('My Products Page', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
