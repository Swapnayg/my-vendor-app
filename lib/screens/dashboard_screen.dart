import 'package:flutter/material.dart';
import '../common/common_layout.dart';
import '../pages/home_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      body: HomePage(),
    );
  }
}
