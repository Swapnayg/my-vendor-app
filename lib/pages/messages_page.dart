import 'package:flutter/material.dart';
import '../common/common_layout.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: const Center(
        child: Text('Messages Page', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
