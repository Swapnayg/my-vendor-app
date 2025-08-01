import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './vendor_drawer.dart';
import 'dart:async';

class CommonLayout extends StatefulWidget {
  final Widget body;

  const CommonLayout({super.key, required this.body});

  @override
  State<CommonLayout> createState() => _CommonLayoutState();
}

class _CommonLayoutState extends State<CommonLayout> {
  String vendorInitial = '';
  int unreadNotifications = 0;
  Timer? _notificationTimer; // Add this line

  @override
  void initState() {
    super.initState();
    fetchVendorNavbarData();

    // 🔁 Set timer to refresh notifications every 60 seconds
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchVendorNavbarData();
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel(); // ✅ Prevent memory leaks
    super.dispose();
  }

  Future<void> fetchVendorNavbarData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final url = Uri.parse(
      'http://localhost:3000/api/MobileApp/vendor/navbar_data',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final username = data['username'] ?? 'V';
        final notifications = data['unreadNotifications'] ?? 0;

        if (mounted) {
          setState(() {
            vendorInitial =
                username.isNotEmpty ? username[0].toUpperCase() : 'V';
            unreadNotifications = notifications;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            vendorInitial = 'V';
            unreadNotifications = 0;
          });
        }
      }
    } catch (e) {
      // Optional: handle error (network issues etc.)
    }
  }

  int _getIndexFromPath(String path) {
    if (path.contains('/orders/latest-orders')) return 1;
    if (path.contains('/add-product')) return 2;
    if (path.contains('/reports')) return 3;
    if (path.contains('/profile')) return 4;
    return 0;
  }

  static const Color logoutColor = Colors.red;

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/orders/latest-orders');
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
        actions: [
          IconButton(
            onPressed: () {
              context.go('/notifications'); // 🔁 Go to notifications page
            },
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none, color: Colors.black),
                if (unreadNotifications > 0)
                  Positioned(
                    top: 5,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadNotifications.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.red.shade100,
            child: Text(
              vendorInitial,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: widget.body,
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
                ? BoxDecoration(borderRadius: BorderRadius.circular(5))
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
