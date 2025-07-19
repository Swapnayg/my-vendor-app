import 'package:flutter/material.dart';
import '/common/common_layout.dart';

class CommissionSummaryPage extends StatelessWidget {
  const CommissionSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: Center(
        child: Text('Commission Summary Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
