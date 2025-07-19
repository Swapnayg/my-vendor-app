import 'package:flutter/material.dart';
import '/common/common_layout.dart';

class OrderTrackPage extends StatelessWidget {
  const OrderTrackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(child: Text('Track Page', style: TextStyle(fontSize: 24))),
    );
  }
}
