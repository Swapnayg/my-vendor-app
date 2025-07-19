import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/pages/orders/management.dart';
import 'package:my_vendor_app/pages/orders/sales-revenue.dart';
import 'package:my_vendor_app/pages/orders/track.dart';
import 'package:my_vendor_app/pages/products/commission-summary.dart';
import 'package:my_vendor_app/pages/products/inventory.dart';
import 'package:my_vendor_app/pages/products/management.dart';
import 'package:my_vendor_app/pages/products/top.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';

import 'pages/home_page.dart';
import 'pages/orders_page.dart';
import 'pages/add_product_page.dart';
import 'pages/reports_page.dart';
import 'pages/profile_page.dart';
import 'pages/my_products_page.dart';
import 'pages/messages_page.dart';
import 'pages/notifications_page.dart';
import 'pages/settings_page.dart';
import 'pages/data_privacy_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/', // Start at splash
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Main App Pages (each with CommonLayout inside them)
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductPage(),
    ),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/products',
      builder: (context, state) => const MyProductsPage(),
    ),
    GoRoute(
      path: '/messages',
      builder: (context, state) => const MessagesPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/settings/data-privacy',
      builder: (context, state) => const DataPrivacyPage(),
    ),
    GoRoute(
      path: '/orders/management',
      builder: (context, state) => const OrderManagementPage(),
    ),
    GoRoute(
      path: '/orders/sales-revenue',
      builder: (context, state) => const SalesRevenuePage(),
    ),
    GoRoute(
      path: '/orders/track',
      builder: (context, state) => const OrderTrackPage(),
    ),
    GoRoute(
      path: '/products/commission-summary',
      builder: (context, state) => const CommissionSummaryPage(),
    ),
    GoRoute(
      path: '/products/inventory',
      builder: (context, state) => const InventoryPage(),
    ),
    GoRoute(
      path: '/products/management',
      builder: (context, state) => const InventoryManagementPage(),
    ),
    GoRoute(
      path: '/products/top',
      builder: (context, state) => const TopproductsPage(),
    ),
  ],
);
