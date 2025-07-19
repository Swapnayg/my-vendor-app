import 'package:flutter/material.dart';

class DataPrivacyPage extends StatefulWidget {
  const DataPrivacyPage({super.key});

  @override
  State<DataPrivacyPage> createState() => _DataPrivacyPageState();
}

class _DataPrivacyPageState extends State<DataPrivacyPage> {
  bool researchInvites = true;
  bool socialDataToggle = true;

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget listTile(
    String title, {
    VoidCallback? onTap,
    bool? switchValue,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing:
              switchValue != null
                  ? Switch(value: switchValue, onChanged: onSwitchChanged)
                  : const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          CircleAvatar(radius: 14, child: Text("JD")),
          SizedBox(width: 12),
        ],
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Section 1
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Who can get in touch with you'),
                  listTile('Invitations', onTap: () {}),
                  listTile('Invitations from your network', onTap: () {}),
                  listTile('Messages', onTap: () {}),
                  listTile(
                    'Research invites',
                    switchValue: researchInvites,
                    onSwitchChanged: (val) {
                      setState(() => researchInvites = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('How app uses your data'),
                  listTile('Manage your data', onTap: () {}),
                  listTile('Salary data', onTap: () {}),
                  listTile('Search data', onTap: () {}),
                  listTile('Demographic information', onTap: () {}),
                  listTile(
                    'Social, economic, and workplace',
                    switchValue: socialDataToggle,
                    onSwitchChanged: (val) {
                      setState(() => socialDataToggle = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}
