import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/models/order.dart';
import 'package:my_vendor_app/models/product.dart';
import 'package:my_vendor_app/models/ticket.dart';
import 'package:my_vendor_app/models/user.dart';
import 'package:my_vendor_app/pages/chat_page.dart';
import 'package:my_vendor_app/pages/orders/manage-order.dart';
import 'package:my_vendor_app/pages/orders/management.dart';
import 'package:my_vendor_app/pages/orders/mark_order_shipped_page.dart';
import 'package:my_vendor_app/pages/orders/order-invoice.dart';
import 'package:my_vendor_app/pages/orders/sales-revenue.dart';
import 'package:my_vendor_app/pages/orders/track.dart';
import 'package:my_vendor_app/pages/products/commission-summary.dart';
import 'package:my_vendor_app/pages/products/inventory.dart';
import 'package:my_vendor_app/pages/products/management.dart';
import 'package:my_vendor_app/pages/products/product-details.dart';
import 'package:my_vendor_app/pages/products/product-stock.dart';
import 'package:my_vendor_app/pages/products/top.dart';
import 'package:my_vendor_app/pages/products/viewproductpage.dart';
import 'package:my_vendor_app/pages/orders/latest_orders_page.dart';
import 'package:my_vendor_app/pages/profile/edit_address_details_page.dart';
import 'package:my_vendor_app/pages/profile/edit_business_details_page.dart';
import 'package:my_vendor_app/pages/profile/edit_contact_details_page.dart';
import 'package:my_vendor_app/pages/profile/edit_kyc_details_page.dart';
import 'package:my_vendor_app/pages/profile/edit_zone_details_page.dart';
import 'package:my_vendor_app/pages/ticket_details.dart';
import 'package:my_vendor_app/pages/ticket_submission.dart';
import 'package:my_vendor_app/pages/tickets.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';

import 'pages/home_page.dart';
import 'pages/add_product_page.dart';
import 'pages/reports_page.dart';
import 'pages/profile_page.dart';
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
      name: 'addProduct',
      builder: (context, state) {
        final product = state.extra as Product?;
        return AddProductPage(initialData: product);
      },
    ),

    GoRoute(
      path: '/view-product',
      name: 'viewProduct',
      builder: (context, state) {
        final product = state.extra as Product;
        return ViewProductPage(product: product);
      },
    ),

    GoRoute(path: '/reports', builder: (context, state) => const ReportsPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/vendor/edit/business',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return EditBusinessDetailsPage(data: data);
      },
    ),
    GoRoute(
      path: '/vendor/edit/contact',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return EditContactDetailsPage(data: data);
      },
    ),
    GoRoute(
      path: '/vendor/edit/address',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return EditAddressPage(data: data);
      },
    ),
    GoRoute(
      path: '/vendor/edit/zone-category',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return EditZoneCategoryPage(data: data);
      },
    ),
    GoRoute(
      path: '/vendor/edit/kyc',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return EditKYCPage(data: data);
      },
    ),

    GoRoute(
      path: '/messages',
      builder: (context, state) => const MessagesPage(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final String customerId = extra['customerId'].toString(); // ✅ FIXED
        final User user = extra['user'];
        return ChatPage(customerId: customerId, user: user);
      },
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/tickets',
      builder: (context, state) => const TicketManagementPage(),
    ),

    GoRoute(
      path: '/tickets/details',
      builder: (context, state) {
        final ticket = Ticket.fromJson(state.extra as Map<String, dynamic>);
        return TicketDetailsPage(ticket: ticket);
      },
    ),

    GoRoute(
      path: '/tickets/raise',
      builder: (context, state) => const RaiseTicketPage(),
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
      path: '/orders/latest-orders',
      builder: (context, state) => const LatestOrdersPage(),
    ),
    GoRoute(
      path: '/orders/management',
      builder: (context, state) => const OrderManagementPage(),
    ),

    GoRoute(
      path: '/orders/mark-shipped',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final orderId = data['orderId'] as String;
        return MarkOrderShippedPage(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/orders/view',
      builder: (context, state) {
        final order =
            state.extra as Order; // Make sure to import your Order model
        return OrderViewPage(order: order);
      },
    ),

    GoRoute(
      path: '/orders/tracking-details',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final orderId = data['orderId'] as String;
        return OrderTrackPage(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/orders/sales-revenue',
      builder: (context, state) => const SalesRevenuePage(),
    ),
    GoRoute(
      path: '/orders/track',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final orderId = data['orderId'] as String;
        return OrderTrackPage(orderId: orderId);
      },
    ),

    GoRoute(
      path: '/orders/invoice',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return InvoicePage(
          order: data['order'],
          source: data['source'] ?? 'latest',
        );
      },
    ),

    GoRoute(
      path: '/products/commission-summary',
      builder: (context, state) => const CommissionSummaryPage(),
    ),
    GoRoute(
      path: '/products/inventory',
      builder: (context, state) => InventoryPage(),
    ),

    GoRoute(
      path: '/products/inventory-stock',
      name: 'inventory-stock',
      builder: (context, state) {
        final product = state.extra as Product;
        return ProductStockUpdatePage(product: product);
      },
    ),

    GoRoute(
      path: '/products/management',
      builder: (context, state) => const ProductManagementPage(),
    ),
    GoRoute(
      path: '/products/top',
      builder: (context, state) => const TopProductsPage(),
    ),
    GoRoute(
      path: '/products/details',
      builder: (context, state) {
        final product = state.extra as Product;
        return ProductDetailsPage(product: product);
      },
    ),
  ],
);
