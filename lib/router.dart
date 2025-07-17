import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

import 'pages/home_page.dart';
import 'pages/orders_page.dart';
import 'pages/add_product_page.dart';
import 'pages/reports_page.dart';
import 'pages/profile_page.dart';

// Splash router shown only initially
final GoRouter splashRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
  ],
);

// Main app router
final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
      routes: [
        GoRoute(path: 'home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: 'orders',
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: 'add-product',
          builder: (context, state) => const AddProductPage(),
        ),
        GoRoute(
          path: 'reports',
          builder: (context, state) => const ReportsPage(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);
