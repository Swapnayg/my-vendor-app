import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_vendor_app/common/common_layout.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _upiIdController = TextEditingController();

  Uint8List? _upiQrBytes;
  String? _upiQrFileName;
  String? _upiQrUrl;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBankDetails();
  }

  Future<void> _loadBankDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/MobileApp/vendor/settings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final account = data['bankAccount'];

      if (account != null) {
        _accountHolderController.text = account['accountHolder'] ?? '';
        _accountNumberController.text = account['accountNumber'] ?? '';
        _ifscCodeController.text = account['ifscCode'] ?? '';
        _bankNameController.text = account['bankName'] ?? '';
        _branchNameController.text = account['branchName'] ?? '';
        _upiIdController.text = account['upiId'] ?? '';
        _upiQrUrl = account['upiQrUrl'];
        _upiQrFileName = _upiQrUrl?.split('/').last;
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickUpiQrFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _upiQrBytes = result.files.single.bytes;
        _upiQrFileName = result.files.single.name;
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(
    Uint8List fileBytes,
    String fileName,
  ) async {
    const cloudName = 'dhas7vy3k';
    const uploadPreset = 'vendors';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
          );

    final response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(resStr);
      return data['secure_url'];
    } else {
      print('Cloudinary upload failed: $resStr');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    // Upload QR image if new file is picked
    String? uploadedUrl = _upiQrUrl;
    if (_upiQrBytes != null && _upiQrFileName != null) {
      uploadedUrl = await _uploadImageToCloudinary(
        _upiQrBytes!,
        _upiQrFileName!,
      );
      if (uploadedUrl == null) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR upload failed. Please try again.')),
        );
        return;
      }
    }

    final uri = Uri.parse(
      'http://localhost:3000/api/MobileApp/vendor/settings',
    );

    final body = {
      'accountHolder': _accountHolderController.text.trim(),
      'accountNumber': _accountNumberController.text.trim(),
      'ifscCode': _ifscCodeController.text.trim(),
      'bankName': _bankNameController.text.trim(),
      'branchName': _branchNameController.text.trim(),
      'upiId': _upiIdController.text.trim(),
      'upiQrUrl': uploadedUrl,
    };

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    setState(() => _isSubmitting = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank details saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed: ${jsonDecode(response.body)['error'] ?? 'Unknown error'}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    children: [
                      const Text(
                        'Bank Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Account Name',
                        _accountHolderController,
                        Icons.person,
                      ),
                      _buildTextField(
                        'Account Number',
                        _accountNumberController,
                        Icons.credit_card,
                        TextInputType.number,
                        r'^\d{9,18}$',
                        'Enter a valid account number',
                      ),
                      _buildTextField(
                        'IFSC Code',
                        _ifscCodeController,
                        Icons.qr_code_scanner,
                        TextInputType.text,
                        r'^[A-Z]{4}0[A-Z0-9]{6}$',
                        'Enter valid IFSC',
                      ),
                      _buildTextField(
                        'Bank Name',
                        _bankNameController,
                        Icons.account_balance,
                      ),
                      _buildTextField(
                        'Branch Name',
                        _branchNameController,
                        Icons.location_city,
                      ),
                      _buildTextField(
                        'UPI ID',
                        _upiIdController,
                        Icons.alternate_email,
                        TextInputType.emailAddress,
                        r'^\w+@\w+$',
                        'Enter a valid UPI ID',
                      ),
                      const SizedBox(height: 16),
                      _buildFilePickerTile(
                        'Upload UPI QR Code',
                        _upiQrFileName,
                        _pickUpiQrFile,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isSubmitting
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'Submit Bank Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
    String? pattern,
    String? errorMsg,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required field';
          if (pattern != null && !RegExp(pattern).hasMatch(value.trim())) {
            return errorMsg;
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerTile(
    String title,
    String? fileName,
    VoidCallback onPick,
  ) {
    return ListTile(
      onTap: onPick,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      title: Text(title),
      subtitle: Text(
        fileName ?? 'No file selected.',
        style: const TextStyle(fontSize: 13),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
