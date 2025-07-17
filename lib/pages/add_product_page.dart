import 'package:flutter/material.dart';
import '../common/common_layout.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(
        child: Text(
          'Add Product Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
