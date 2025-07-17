import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorDrawer extends StatelessWidget {
  final String activeRoute;
  const VendorDrawer({super.key, required this.activeRoute});

  Widget _buildBadge(Widget icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          )
      ],
    );
  }

  Widget _drawerItem(
    BuildContext context,
    String title,
    String route,
    IconData icon, {
    int badgeCount = 0,
  }) {
    final isActive = activeRoute == route;
    return ListTile(
      leading: _buildBadge(
        Icon(icon, color: isActive ? Colors.blue : Colors.black),
        badgeCount,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.blue : Colors.black,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        context.pop(); // close the drawer
        context.go(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            // Profile Header
            Row(
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      AssetImage('assets/images/vendor_avatar.jpg'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MarketFlow Inc.',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('support@marketflow.com',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Navigation Items
            _drawerItem(
                context, 'Dashboard', '/dashboard/home', Icons.dashboard),
            _drawerItem(context, 'Orders', '/dashboard/orders',
                Icons.shopping_bag_outlined,
                badgeCount: 7),
            _drawerItem(context, 'My Products', '/dashboard/add-product',
                Icons.add_box_outlined),
            _drawerItem(
                context, 'Reports', '/dashboard/reports', Icons.bar_chart),
            _drawerItem(
                context, 'Profile', '/dashboard/profile', Icons.person_outline),

            const Divider(height: 32),

            // Optional Items
            _drawerItem(context, 'Messages', '/dashboard/messages',
                Icons.message_outlined,
                badgeCount: 3),
            _drawerItem(context, 'Notifications', '/dashboard/notifications',
                Icons.notifications_none,
                badgeCount: 12),
            _drawerItem(
                context, 'Settings', '/dashboard/settings', Icons.settings),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // 🔐 Add logout logic here (Supabase signOut etc.)
              },
            ),
          ],
        ),
      ),
    );
  }
}
