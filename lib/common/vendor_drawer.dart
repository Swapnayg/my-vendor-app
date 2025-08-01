import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VendorDrawer extends StatefulWidget {
  final String activeRoute;
  const VendorDrawer({super.key, required this.activeRoute});

  @override
  State<VendorDrawer> createState() => _VendorDrawerState();
}

class _VendorDrawerState extends State<VendorDrawer> {
  static const Color highlightColor = Color(0xFFFFC300);
  static const Color sectionBackground = Color(0xFFFFF0CC);
  static const Color highlightBackground = Color(0xFFFFE5A0);
  static const Color logoutColor = Colors.red;
  static final Color iconColor = Colors.grey[600]!;

  Map<String, bool> expandedSections = {
    'Orders': false,
    'My Products': false,
    'Support': false,
    'Settings': false,
  };

  String businessName = '';
  String email = '';
  String profileImage = '';
  int unreadMessages = 0;
  int unreadNotifications = 0;
  int openTickets = 0;

  @override
  void initState() {
    super.initState();
    fetchVendorProfileData();
  }

  Future<void> fetchVendorProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/MobileApp/vendor/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        businessName = data['businessName'] ?? '';
        email = data['email'] ?? '';
        profileImage = data['profileImage'] ?? '';
        unreadMessages = data['unreadMessages'] ?? 0;
        unreadNotifications = data['unreadNotifications'] ?? 0;
        openTickets = data['openTickets'] ?? 0;
      });
    } else {
      debugPrint('Failed to load profile: ${response.body}');
    }
  }

  Widget _buildBadge(int count) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    String title,
    String route,
    IconData icon, {
    int badgeCount = 0,
  }) {
    final isActive = widget.activeRoute == route;
    final Color currentColor = isActive ? logoutColor : Colors.black;

    return Container(
      decoration:
          isActive
              ? BoxDecoration(
                color: highlightBackground,
                borderRadius: BorderRadius.circular(5),
              )
              : null,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: Icon(icon, color: currentColor, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: currentColor,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount > 0) _buildBadge(badgeCount),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
        onTap: () {
          context.pop();
          context.go(route);
        },
      ),
    );
  }

  Widget _drawerSection(String title) {
    final hasSubmenu = expandedSections.containsKey(title);
    final isExpanded = expandedSections[title] ?? false;

    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
      trailing:
          hasSubmenu
              ? Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
              )
              : null,
      onTap:
          hasSubmenu
              ? () => setState(() {
                expandedSections[title] = !isExpanded;
              })
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        profileImage.isNotEmpty
                            ? NetworkImage(profileImage)
                            : const AssetImage('assets/images/upload.png')
                                as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerSection('Dashboard'),
                  _drawerItem(context, 'Dashboard', '/home', Icons.dashboard),

                  _drawerSection('Orders'),
                  if (expandedSections['Orders'] == true) ...[
                    _drawerItem(
                      context,
                      'Order Management',
                      '/orders/management',
                      Icons.list_alt,
                    ),
                    _drawerItem(
                      context,
                      'Recent Orders',
                      '/orders/latest-orders',
                      Icons.track_changes,
                    ),
                    _drawerItem(
                      context,
                      'Sales Revenue',
                      '/orders/sales-revenue',
                      Icons.pie_chart,
                    ),
                  ],

                  _drawerSection('My Products'),
                  if (expandedSections['My Products'] == true) ...[
                    _drawerItem(
                      context,
                      'Product Management',
                      '/products/management',
                      Icons.widgets,
                    ),
                    _drawerItem(
                      context,
                      'Product Inventory',
                      '/products/inventory',
                      Icons.inventory,
                    ),
                    _drawerItem(
                      context,
                      'Top Products',
                      '/products/top',
                      Icons.star_outline,
                    ),
                    _drawerItem(
                      context,
                      'Commission Summary',
                      '/products/commission-summary',
                      Icons.monetization_on,
                    ),
                  ],

                  _drawerSection('Messages'),
                  _drawerItem(
                    context,
                    'Messages',
                    '/messages',
                    Icons.message,
                    badgeCount: unreadMessages,
                  ),

                  _drawerSection('Notifications'),
                  _drawerItem(
                    context,
                    'Notifications',
                    '/notifications',
                    Icons.notifications,
                    badgeCount: unreadNotifications,
                  ),

                  _drawerSection('Tickets'),
                  _drawerItem(
                    context,
                    'Tickets',
                    '/tickets',
                    Icons.confirmation_number_outlined,
                    badgeCount: openTickets,
                  ),

                  _drawerSection('Reports'),
                  _drawerItem(context, 'Reports', '/reports', Icons.bar_chart),

                  _drawerSection('Profile'),
                  _drawerItem(context, 'Profile', '/profile', Icons.person),

                  _drawerSection('Settings'),
                  if (expandedSections['Settings'] == true) ...[
                    _drawerItem(
                      context,
                      'Settings',
                      '/settings',
                      Icons.settings,
                    ),
                    _drawerItem(
                      context,
                      'Data Privacy',
                      '/settings/data-privacy',
                      Icons.privacy_tip,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: logoutColor),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: logoutColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
                context.go('/login');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
