import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_vendor_app/common/common_layout.dart'; // Ensure this import matches your project structure

class EditZoneCategoryPage extends StatefulWidget {
  final Map<String, dynamic>? data;

  const EditZoneCategoryPage({super.key, this.data});

  @override
  State<EditZoneCategoryPage> createState() => _EditZoneCategoryPageState();
}

class _EditZoneCategoryPageState extends State<EditZoneCategoryPage> {
  List<dynamic> categories = [];
  List<dynamic> zones = [];
  String? selectedCategoryId;
  Set<int> selectedZoneIds = {};
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final categoryResponse = await http.get(
        Uri.parse(
          "http://localhost:3000/api/MobileApp/vendor/vendor-categories",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      final zoneResponse = await http.get(
        Uri.parse("http://localhost:3000/api/MobileApp/vendor/location-zones"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (categoryResponse.statusCode == 200 &&
          zoneResponse.statusCode == 200) {
        final categoryData = jsonDecode(categoryResponse.body)["data"];
        final zoneData = jsonDecode(zoneResponse.body)["data"];

        final passedZoneIds =
            (widget.data?['zoneId'] as List?)?.cast<int>() ?? [];
        final passedZoneDetails = widget.data?['zones'] as List<dynamic>?;

        List<dynamic> resolvedZones =
            passedZoneDetails ??
            zoneData.where((z) => passedZoneIds.contains(z['id'])).toList();

        setState(() {
          categories = categoryData;
          zones = zoneData;
          selectedCategoryId = widget.data?['categoryId']?.toString();
          selectedZoneIds = Set<int>.from(
            resolvedZones.map((z) => z['id'] as int),
          );
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    if (selectedZoneIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one zone.')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("http://localhost:3000/api/MobileApp/vendor/zone-details"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "categoryId": int.parse(selectedCategoryId!),
          "zoneIds": selectedZoneIds.toList(),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully.'),
            backgroundColor: Colors.green,
          ),
        ); // Go back or use context.go('/profile') if needed
      } else {
        throw Exception(responseData['error'] ?? 'Failed to update');
      }
    } catch (e) {
      debugPrint("Submit Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorId = widget.data?['vendorId'];

    return CommonLayout(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed:
                              isSubmitting
                                  ? null
                                  : () => context.go('/profile'),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Edit Category & Zones",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      "Vendor ID: $vendorId",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    /// Category Dropdown
                    const Text(
                      "Select Category",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items:
                          categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat["id"].toString(),
                                  child: Text(cat["name"]),
                                ),
                              )
                              .toList(),
                      onChanged:
                          isSubmitting
                              ? null
                              : (val) =>
                                  setState(() => selectedCategoryId = val),
                    ),

                    const SizedBox(height: 24),

                    /// Zones Multi-select
                    const Text(
                      "Select Zones",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    zones.isNotEmpty
                        ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              zones.map((zone) {
                                final id = zone['id'] as int;
                                final name = zone['name'] ?? 'Unnamed';
                                return FilterChip(
                                  label: Text(name),
                                  selected: selectedZoneIds.contains(id),
                                  onSelected:
                                      isSubmitting
                                          ? null
                                          : (selected) {
                                            setState(() {
                                              if (selected) {
                                                selectedZoneIds.add(id);
                                              } else {
                                                selectedZoneIds.remove(id);
                                              }
                                            });
                                          },
                                );
                              }).toList(),
                        )
                        : const Text("No zones available."),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor:
                                  Colors
                                      .white, // Sets text and spinner color to white
                            ),
                            onPressed: isSubmitting ? null : _submit,
                            child:
                                isSubmitting
                                    ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      "Save Changes",
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isSubmitting
                                    ? null
                                    : () => context.go('/profile'),
                            child: const Text("Cancel"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
