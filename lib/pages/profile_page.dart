import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/kyc.dart';
import 'package:my_vendor_app/models/location_zone.dart';
import 'package:my_vendor_app/models/vendor.dart';
import 'package:my_vendor_app/models/vendor_category.dart';
import 'package:my_vendor_app/pages/KYCPreviewPage.dart';

final _mockVendor = Vendor(
  id: 1,
  userId: 1,
  businessName: 'TechSpark Pvt Ltd',
  gstNumber: '27ABCDE1234F1Z5',
  phone: '+91 9876543210',
  address: '123 Tech Park, Sector 21',
  city: 'Bengaluru',
  state: 'Karnataka',
  zipcode: '560103',
  website: 'www.techspark.com',
  contactName: 'Ravi Kumar',
  contactEmail: 'ravi@techspark.com',
  contactPhone: '+91 9999988888',
  designation: 'Director',
  status: VendorStatus.APPROVED,
  createdAt: DateTime.now(),
  category: VendorCategory(id: 1, name: 'Electronics'),
  zone: LocationZone(id: 1, name: 'South Zone', country: ''),
  kycDocuments: [
    KYC(
      id: 1,
      vendorId: 1,
      type: 'PAN Card',
      fileUrl: 'https://example.com/pan.pdf',
      verified: true,
    ),
    KYC(
      id: 2,
      vendorId: 1,
      type: 'Aadhar Card',
      fileUrl: 'https://example.com/aadhar.pdf',
      verified: true,
    ),
  ],
);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vendor = _mockVendor; // Replace with API later

    return CommonLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(context, vendor),
            const SizedBox(height: 16),
            _buildSectionCard("Business Details", [
              _buildRow("Business Name", vendor.businessName),
              _buildRow("GST Number", vendor.gstNumber ?? "-"),
              _buildRow("Website", vendor.website ?? "-"),
            ], onEdit: () => context.go('/vendor/edit/business')),
            _buildSectionCard("Contact Details", [
              _buildRow("Contact Name", vendor.contactName ?? "-"),
              _buildRow("Contact Email", vendor.contactEmail ?? "-"),
              _buildRow("Contact Phone", vendor.contactPhone ?? "-"),
              _buildRow("Designation", vendor.designation ?? "-"),
            ], onEdit: () => context.go('/vendor/edit/contact')),
            _buildSectionCard("Address", [
              _buildRow("Phone", vendor.phone),
              _buildRow("Address", vendor.address),
              _buildRow("City", vendor.city ?? "-"),
              _buildRow("State", vendor.state ?? "-"),
              _buildRow("Zipcode", vendor.zipcode ?? "-"),
            ], onEdit: () => context.go('/vendor/edit/address')),
            _buildSectionCard(
              "Zone & Category",
              [
                _buildRow("Category", vendor.category?.name ?? "-"),
                _buildRow("Zone", vendor.zone?.name ?? "-"),
                _buildRow("Status", vendor.status.name),
                _buildRow(
                  "Created At",
                  DateFormat('MMMM dd, yyyy').format(vendor.createdAt),
                ),
              ],
              onEdit: () => context.go('/vendor/edit/zone-category'),
            ),
            _buildSectionCard(
              "KYC Documents",
              vendor.kycDocuments.isNotEmpty
                  ? vendor.kycDocuments
                      .map((doc) => _buildKycRow(context, doc))
                      .toList()
                  : [_buildRow("No documents", "")],
              onEdit: () => context.go('/vendor/edit/kyc'),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                // Add deletion logic here
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Vendor vendor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue.shade300,
            child: Text(
              _getInitials(vendor.businessName),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.businessName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Your Business Journey Awaits",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    List<Widget> children, {
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  onPressed: onEdit,
                  tooltip: "Edit $title",
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildKycRow(BuildContext context, KYC doc) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KYCPreviewPage(title: doc.type, url: doc.fileUrl),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                doc.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7C3AED),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(" ");
    return parts.length >= 2 ? "${parts[0][0]}${parts[1][0]}" : parts[0][0];
  }
}
