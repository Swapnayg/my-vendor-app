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
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _populateInitialData();
  }

  void _populateInitialData() {
    final data = widget.data;

    _phoneController.text = data?['phone'] ?? '';
    _addressController.text = data?['address'] ?? '';
    _cityController.text = data?['city'] ?? '';
    _stateController.text = data?['state'] ?? '';
    _zipcodeController.text = data?['zipcode'] ?? '';
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

    print("Sending update request with body: $body");

    final response = await http.post(
      Uri.parse(
        "http://localhost:3000/api/MobileApp/vendor/address_details",
      ), // ✅ correct endpoint
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (res["success"] == true && mounted) {
        setState(() => isSubmitting = false); // ✅ FIXED HERE
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Address updated successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a moment to let the user see the message
        await Future.delayed(const Duration(milliseconds: 1500));
      } else {
        _showError("Failed to update address");
        setState(() => isSubmitting = false); // ✅ handle error too
      }
    } else {
      _showError("Server error");
      setState(() => isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Padding(
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          child: ElevatedButton(
            onPressed:
                isSubmitting
                    ? null
                    : () async {
                      final valid = _formKey.currentState!.validate();
                      if (valid) {
                        setState(() => isSubmitting = true);
                        try {
                          await _submitUpdate();
                        } finally {
                          if (mounted) {
                            setState(() => isSubmitting = false);
                          }
                        }
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              elevation: 0,
            ),
            child:
                isSubmitting
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text("Save Changes"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : () => context.go('/profile'),
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
