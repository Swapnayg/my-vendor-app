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

  static const Color logoutColor = Colors.red;

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        context.go('/add-product');
        break;
      case 3:
        context.go('/reports');
        break;
      case 4:
        context.go('/profile');
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
        title: const Text("Vendor App", style: TextStyle(color: Colors.black)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/images/upload.png'),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(index, context),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          _customNavItem(Icons.home_outlined, 'Home', 0, currentIndex),
          _customNavItem(
            Icons.shopping_bag_outlined,
            'Orders',
            1,
            currentIndex,
          ),
          _customNavItem(Icons.add_box_outlined, 'Add', 2, currentIndex),
          _customNavItem(Icons.bar_chart, 'Reports', 3, currentIndex),
          _customNavItem(Icons.person_outline, 'Profile', 4, currentIndex),
        ],
      ),
    );
  }

  BottomNavigationBarItem _customNavItem(
    IconData icon,
    String label,
    int index,
    int currentIndex,
  ) {
    final bool isSelected = index == currentIndex;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration:
            isSelected
                ? BoxDecoration(
                  //color: VendorDrawer.highlightBackground,
                  borderRadius: BorderRadius.circular(5),
                )
                : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? logoutColor : Colors.grey),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? logoutColor : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      label: '',
    );
  }
}
