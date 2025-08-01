import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> allNotifications = [];
  NotificationType? selectedType;
  String searchQuery = '';
  bool showUnreadOnly = false;
  bool sortDescending = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> markNotificationAsRead({
    String? notificationId,
    bool markAll = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final response = await http.post(
        Uri.parse(
          'http://localhost:3000/api/MobileApp/vendor/mark-notification',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (markAll) 'markAll': true,
          if (!markAll && notificationId != null)
            'notificationId': notificationId,
        }),
      );

      if (response.statusCode == 200) {
        // Optional: log or show success
      } else {
        print("Failed to mark notification(s): ${response.body}");
      }
    } catch (e) {
      print("Error marking notification(s): $e");
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/MobileApp/vendor/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['notifications'];

        setState(() {
          allNotifications =
              data.map((n) => NotificationModel.fromJson(n)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load notifications");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      setState(() => isLoading = false);
    }
  }

  void _openFilterPopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text("Show Unread Only"),
                    value: showUnreadOnly,
                    onChanged:
                        (val) => setSheetState(() => showUnreadOnly = val),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<bool>(
                    decoration: const InputDecoration(labelText: "Sort by"),
                    value: sortDescending,
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text("Newest First"),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text("Oldest First"),
                      ),
                    ],
                    onChanged:
                        (val) => setSheetState(() => sortDescending = val!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text("Apply Filters"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<NotificationModel> get filteredNotifications {
    List<NotificationModel> filtered = [...allNotifications];

    if (selectedType != null) {
      filtered = filtered.where((n) => n.type == selectedType).toList();
    }

    if (showUnreadOnly) {
      filtered = filtered.where((n) => !n.read).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (n) =>
                    n.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    n.message.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();
    }

    filtered.sort(
      (a, b) =>
          sortDescending
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt),
    );

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: _openFilterPopup,
                  tooltip: 'Filter Notifications',
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Search notifications...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildFilterChip(null, "All"),
                for (var type in NotificationType.values)
                  _buildFilterChip(type, _getLabelForType(type)),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await markNotificationAsRead(markAll: true);

                  setState(() {
                    allNotifications =
                        allNotifications
                            .map((n) => n.copyWith(read: true))
                            .toList();
                  });
                },
                child: const Text("Mark all as read"),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredNotifications.isEmpty
                      ? const Center(child: Text("No notifications found."))
                      : ListView.builder(
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notif = filteredNotifications[index];
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () async {
                                if (!notif.read) {
                                  await markNotificationAsRead(
                                    notificationId: notif.id.toString(),
                                  );

                                  setState(() {
                                    final indexInAll = allNotifications
                                        .indexWhere((n) => n.id == notif.id);
                                    if (indexInAll != -1) {
                                      allNotifications[indexInAll] = notif
                                          .copyWith(read: true);
                                    }
                                  });
                                }
                              },

                              leading: CircleAvatar(
                                backgroundColor: Colors.pink.shade50,
                                child: Icon(
                                  _getIconForType(notif.type),
                                  color: Colors.pink,
                                ),
                              ),
                              title: Text(notif.title),
                              subtitle: Text(notif.message),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMM d, h:mm a',
                                    ).format(notif.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (!notif.read)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        "Unread",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(NotificationType? type, String label) {
    final selected = selectedType == type;
    final icon = _getIconForType(type ?? NotificationType.GENERAL);

    return ChoiceChip(
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: selected ? Colors.white : Colors.pink),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => setState(() => selectedType = type),
      selectedColor: Colors.pink,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Colors.grey),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  String _getLabelForType(NotificationType type) {
    switch (type) {
      case NotificationType.ORDER_UPDATE:
        return "Order";
      case NotificationType.PRODUCT_STATUS:
        return "Product";
      case NotificationType.VENDOR_APPROVAL:
        return "Approval";
      case NotificationType.VENDOR_REGISTRATION:
        return "Registration";
      case NotificationType.ADMIN_ALERT:
        return "Admin";
      case NotificationType.GENERAL:
        return "General";
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.ORDER_UPDATE:
        return Icons.local_shipping_outlined;
      case NotificationType.PRODUCT_STATUS:
        return Icons.inventory_2_outlined;
      case NotificationType.VENDOR_APPROVAL:
        return Icons.verified_outlined;
      case NotificationType.VENDOR_REGISTRATION:
        return Icons.store_mall_directory_outlined;
      case NotificationType.ADMIN_ALERT:
        return Icons.warning_amber_outlined;
      case NotificationType.GENERAL:
        return Icons.notifications_none;
    }
  }
}
