import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/common/common_layout.dart';

class EditContactDetailsPage extends StatefulWidget {
  const EditContactDetailsPage({super.key});

  @override
  State<EditContactDetailsPage> createState() => _EditContactDetailsPageState();
}

class _EditContactDetailsPageState extends State<EditContactDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Ravi Kumar");
  final _emailController = TextEditingController(text: "ravi@techspark.com");
  final _phoneController = TextEditingController(text: "+91 9999988888");
  final _designationController = TextEditingController(text: "Director");

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
        if (isEmail && val != null && !val.contains('@'))
          return "Invalid email";
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
            onPressed: () {
              if (_formKey.currentState!.validate()) context.pop();
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
