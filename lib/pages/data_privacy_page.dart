import 'package:flutter/material.dart';
import '../common/common_layout.dart'; // Adjust the import as per your structure

class DataPrivacyPage extends StatelessWidget {
  const DataPrivacyPage({super.key});

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget infoBullet(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6, // Increased line height
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: "$title\n",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Section 1: Contact Permissions
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              margin: const EdgeInsets.only(
                bottom: 32,
              ), // More space after section
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle("Who can contact you"),
                  infoBullet(
                    "Invitations",
                    "You may receive invites from our verified vendors and service partners based on your activity and preferences.",
                  ),
                  infoBullet(
                    "Invitations from network",
                    "Your existing network of partners and vendors can reach out with relevant offerings or updates.",
                  ),
                  infoBullet(
                    "Messages",
                    "Messages from connected users and authorized vendor support may appear in your inbox.",
                  ),
                  infoBullet(
                    "Research participation",
                    "You may occasionally receive requests to participate in research or feedback sessions to improve our services.",
                  ),
                ],
              ),
            ),

            // Section 2: Data Usage Info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle("How your data is used"),
                  infoBullet(
                    "Account and activity data",
                    "Used to enhance your experience, enable relevant features, and provide personalized content.",
                  ),
                  infoBullet(
                    "Salary and financial data",
                    "If shared, it is used only in anonymized form for analytics and business intelligence. Not disclosed publicly.",
                  ),
                  infoBullet(
                    "Search and interaction behavior",
                    "Helps improve navigation and highlight the most useful features based on usage trends.",
                  ),
                  infoBullet(
                    "Demographics and profile info",
                    "Used to better understand our user base and improve inclusive experiences. Not shared externally.",
                  ),
                  infoBullet(
                    "Social & workplace insights",
                    "Aggregated data may be used to generate insights, but never in a way that personally identifies you.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
