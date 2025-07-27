import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditContactDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? data;

  const EditContactDetailsPage({super.key, this.data});

  @override
  State<EditContactDetailsPage> createState() => _EditContactDetailsPageState();
}

class _EditContactDetailsPageState extends State<EditContactDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateInitialData();
  }

  void _populateInitialData() {
    final data = widget.data;
    if (data != null) {
      _nameController.text = data['contact_name'] ?? '';
      _emailController.text = data['contact_email'] ?? '';
      _phoneController.text = data['contact_phone'] ?? '';
      _designationController.text = data['designation'] ?? '';
    } else {
      _nameController.text = "Ravi Kumar";
      _emailController.text = "ravi@techspark.com";
      _phoneController.text = "+91 9999988888";
      _designationController.text = "Director";
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(
          'https://vendor-admin-portal.netlify.app/api/MobileApp/vendor/contact-details',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contact_name': _nameController.text.trim(),
          'contact_email': _emailController.text.trim(),
          'contact_phone': _phoneController.text.trim(),
          'designation': _designationController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact details updated successfully')),
        );
        context.pop();
      } else {
        throw data['message'] ?? 'Update failed';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  "Edit Contact Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Expanded(
                child: Column(
                  children: [
                    _buildField(_nameController, "Contact Name", true),
                    const SizedBox(height: 16),
                    _buildField(
                      _emailController,
                      "Contact Email",
                      true,
                      isEmail: true,
                    ),
                    const SizedBox(height: 16),
                    _buildField(_phoneController, "Contact Phone", true),
                    const SizedBox(height: 16),
                    _buildField(_designationController, "Designation", true),
                    const Spacer(),
                    _buildActions(context),
                  ],
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
    bool required, {
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: (val) {
        if (required && (val == null || val.trim().isEmpty)) return "Required";
        if (isEmail && val != null && !val.contains('@')) {
          return "Invalid email";
        }
        return null;
      },
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

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: _isLoading ? null : _submitForm,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => context.go('/profile'),
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
