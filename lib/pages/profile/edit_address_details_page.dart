import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_vendor_app/common/common_layout.dart';

class EditAddressPage extends StatefulWidget {
  final Map<String, dynamic>? data;

  const EditAddressPage({super.key, this.data});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _populateInitialData();
  }

  void _populateInitialData() {
    final data = widget.data;

    if (data != null) {
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _cityController.text = data['city'] ?? '';
      _stateController.text = data['state'] ?? '';
      _zipcodeController.text = data['zipcode'] ?? '';
      setState(() => isLoading = false);
    } else {
      _fetchAddress(); // fallback
    }
  }

  Future<void> _fetchAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
        "https://vendor-admin-portal.netlify.app/api/MobileApp/vendor/address_details",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"];
      _phoneController.text = data["phone"] ?? "";
      _addressController.text = data["address"] ?? "";
      _cityController.text = data["city"] ?? "";
      _stateController.text = data["state"] ?? "";
      _zipcodeController.text = data["zipcode"] ?? "";
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _submitUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final body = {
      "phone": _phoneController.text,
      "address": _addressController.text,
      "city": _cityController.text,
      "state": _stateController.text,
      "zipcode": _zipcodeController.text,
    };

    final response = await http.post(
      Uri.parse(
        "https://vendor-admin-portal.netlify.app/api/MobileApp/vendor/update-address",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (res["success"] == true && mounted) {
        context.pop(); // return to previous screen
      } else {
        _showError("Failed to update address");
      }
    } else {
      _showError("Server error");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.go('/profile'),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Edit Address",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildField(_phoneController, "Phone", true),
                              const SizedBox(height: 16),
                              _buildField(_addressController, "Address", true),
                              const SizedBox(height: 16),
                              _buildField(_cityController, "City", true),
                              const SizedBox(height: 16),
                              _buildField(_stateController, "State", true),
                              const SizedBox(height: 16),
                              _buildField(_zipcodeController, "Zipcode", true),
                              const SizedBox(height: 30),
                              _buildActions(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    bool required,
  ) {
    return TextFormField(
      controller: controller,
      validator:
          (val) => required && (val == null || val.isEmpty) ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _submitUpdate();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Save Changes"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/profile'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Cancel"),
          ),
        ),
      ],
    );
  }
}
