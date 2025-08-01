import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/kyc.dart';
import 'package:my_vendor_app/models/vendor.dart';
import 'package:my_vendor_app/pages/KYCPreviewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Vendor? vendor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVendorData();
  }

  Future<void> fetchVendorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("Token not found");
      }

      final res = await http.get(
        Uri.parse('http://localhost:3000/api/MobileApp/vendor/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['vendor'];
        setState(() {
          vendor = Vendor.fromJson(data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load profile data");
      }
    } catch (e) {
      print("Error loading profile: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : vendor == null
              ? const Center(child: Text("Failed to load vendor data"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeaderCard(context, vendor!),
                    const SizedBox(height: 16),

                    _buildSectionCard(
                      "Business Details",
                      [
                        _buildRow("Business Name", vendor!.businessName),
                        _buildRow("GST Number", vendor!.gstNumber ?? "-"),
                        _buildRow("Website", vendor!.website ?? "-"),
                      ],
                      onEdit:
                          () => context.go(
                            '/vendor/edit/business',
                            extra: {
                              'businessName': vendor!.businessName,
                              'gstNumber': vendor!.gstNumber,
                              'website': vendor!.website,
                            },
                          ),
                    ),
                    _buildSectionCard(
                      "Contact Details",
                      [
                        _buildRow("Contact Name", vendor!.contactName ?? "-"),
                        _buildRow("Contact Email", vendor!.contactEmail ?? "-"),
                        _buildRow("Contact Phone", vendor!.contactPhone ?? "-"),
                        _buildRow("Designation", vendor!.designation ?? "-"),
                      ],
                      onEdit:
                          () => context.go(
                            '/vendor/edit/contact',
                            extra: {
                              'contactName': vendor!.contactName,
                              'contactEmail': vendor!.contactEmail,
                              'contactPhone': vendor!.contactPhone,
                              'designation': vendor!.designation,
                            },
                          ),
                    ),
                    _buildSectionCard(
                      "Address",
                      [
                        _buildRow("Phone", vendor!.phone),
                        _buildRow("Address", vendor!.address),
                        _buildRow("City", vendor!.city ?? "-"),
                        _buildRow("State", vendor!.state ?? "-"),
                        _buildRow("Zipcode", vendor!.zipcode ?? "-"),
                      ],
                      onEdit:
                          () => context.go(
                            '/vendor/edit/address',
                            extra: {
                              'phone': vendor!.phone,
                              'address': vendor!.address,
                              'city': vendor!.city,
                              'state': vendor!.state,
                              'zipcode': vendor!.zipcode,
                            },
                          ),
                    ),
                    _buildSectionCard(
                      "Zone & Category",
                      [
                        _buildRow("Category", vendor!.category?.name ?? "-"),
                        _buildRow(
                          "Zone(s)",
                          vendor!.zones.isNotEmpty
                              ? vendor!.zones
                                  .map((vz) => vz.zone.name)
                                  .join(', ')
                              : "-",
                        ),
                        _buildRow(
                          "Country(s)",
                          vendor!.zones.isNotEmpty
                              ? vendor!.zones
                                  .map((vz) => vz.zone.country ?? "-")
                                  .join(', ')
                              : "-",
                        ),
                        _buildRow(
                          "Region(s)",
                          vendor!.zones.isNotEmpty
                              ? vendor!.zones
                                  .map((vz) => vz.zone.region ?? "-")
                                  .join(', ')
                              : "-",
                        ),
                        _buildRow("Status", vendor!.status.name),
                        _buildRow(
                          "Created At",
                          DateFormat('MMMM dd, yyyy').format(vendor!.createdAt),
                        ),
                      ],
                      onEdit:
                          () => context.go(
                            '/vendor/edit/zone-category',
                            extra: {
                              'vendorId': vendor!.id,
                              'zoneId':
                                  vendor!.zones
                                      .map((vz) => vz.zone.id)
                                      .toList(),
                              'categoryId': vendor!.category?.id,
                            },
                          ),
                    ),
                    _buildSectionCard(
                      "KYC Documents",
                      vendor!.kycDocuments.isNotEmpty
                          ? vendor!.kycDocuments
                              .map((doc) => _buildKycRow(context, doc))
                              .toList()
                          : [_buildRow("No documents", "")],
                      onEdit:
                          () => context.go(
                            '/vendor/edit/kyc',
                            extra: {
                              'kycDocuments':
                                  vendor!.kycDocuments
                                      .map(
                                        (doc) => {
                                          'type': doc.type,
                                          'fileUrl': doc.fileUrl,
                                        },
                                      )
                                      .toList(),
                            },
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: const Text(
                                  "Are you sure you want to delete your account? This action is irreversible.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirmed == true) {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');

                            if (token == null) {
                              throw Exception("Token not found");
                            }

                            final res = await http.post(
                              Uri.parse(
                                'http://localhost:3000/api/MobileApp/vendor/delete-vendor',
                              ),
                              headers: {
                                'Authorization': 'Bearer $token',
                                'Content-Type': 'application/json',
                              },
                            );

                            final result = jsonDecode(res.body);
                            if (res.statusCode == 200) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Account deletion requested successfully",
                                    ),
                                  ),
                                );
                                prefs.clear(); // Log out the user
                                context.go(
                                  '/login',
                                ); // Redirect to login or welcome screen
                              }
                            } else {
                              throw Exception(
                                result['error'] ?? "Failed to delete account",
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: ${e.toString()}"),
                                ),
                              );
                            }
                          }
                        }
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
