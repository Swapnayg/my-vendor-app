import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NotificationWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isNew;

  const NotificationWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: const TextStyle(fontSize: 12)),
          if (isNew)
            const Chip(
              label: Text("New"),
              backgroundColor: Colors.orange,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
