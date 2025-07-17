import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './vendor_drawer.dart';

class CommonLayout extends StatelessWidget {
  final Widget body;

  const CommonLayout({super.key, required this.body});

  int _getIndexFromPath(String path) {
    if (path.contains('/orders')) return 1;
    if (path.contains('/add-product')) return 2;
    if (path.contains('/reports')) return 3;
    if (path.contains('/profile')) return 4;
    return 0; // Default is home
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard/home');
        break;
      case 1:
        context.go('/dashboard/orders');
        break;
      case 2:
        context.go('/dashboard/add-product');
        break;
      case 3:
        context.go('/dashboard/reports');
        break;
      case 4:
        context.go('/dashboard/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.toString();
    final currentIndex = _getIndexFromPath(path);

    return Scaffold(
      drawer: VendorDrawer(activeRoute: path),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Vendor App",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/images/profile.jpg'),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
