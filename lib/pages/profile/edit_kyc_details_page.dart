import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditKYCPage extends StatefulWidget {
  const EditKYCPage({super.key});

  @override
  State<EditKYCPage> createState() => _EditKYCPageState();
}

class _EditKYCPageState extends State<EditKYCPage> {
  File? _panFile;
  File? _addressFile;
  File? _gstFile;

  String? _panFileName = "pan_card.jpg";
  String? _addressFileName = "address_proof.pdf";
  String? _gstFileName = "No file selected";

  String? _existingPanUrl;
  String? _existingAddressUrl;
  String? _existingGstUrl;

  @override
  void initState() {
    super.initState();
    _loadExistingKyc();
  }

  Future<void> _loadExistingKyc() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
        'https://vendor-admin-portal.netlify.app/api/MobileApp/vendor/kyc-details',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _existingPanUrl = data['pan'];
        _existingAddressUrl = data['address_proof'];
        _existingGstUrl = data['gst_certificate'];
      });
    }
  }

  Future<String> _uploadToCloudinary(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/dhas7vy3k/image/upload',
    );
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = 'vendors'; // Replace later
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody);

    return json['secure_url'];
  }

  Future<void> _pickFile(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      final name = result.files.first.name;

      setState(() {
        if (docType == "PAN") {
          _panFile = file;
          _panFileName = name;
        } else if (docType == "ADDRESS") {
          _addressFile = file;
          _addressFileName = name;
        } else if (docType == "GST") {
          _gstFile = file;
          _gstFileName = name;
        }
      });
    }
  }

  Future<void> _submitKYC() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    String? panUrl =
        _panFile != null
            ? await _uploadToCloudinary(_panFile!)
            : _existingPanUrl;
    String? addressUrl =
        _addressFile != null
            ? await _uploadToCloudinary(_addressFile!)
            : _existingAddressUrl;
    String? gstUrl =
        _gstFile != null
            ? await _uploadToCloudinary(_gstFile!)
            : _existingGstUrl;

    final response = await http.post(
      Uri.parse(
        'https://vendor-admin-portal.netlify.app/api/MobileApp/vendor/kyc-details',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pan': panUrl,
        'address_proof': addressUrl,
        'gst_certificate': gstUrl,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("KYC updated successfully")));
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update KYC (${response.statusCode})"),
        ),
      );
    }
  }

  Widget _buildUploadTile({
    required String label,
    required String fileName,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ${isOptional ? '(Optional)' : ''}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
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
                  "Edit KYC Documents",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Upload new KYC documents below:",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            _buildUploadTile(
              label: "PAN Card",
              fileName: _panFileName ?? 'No file selected',
              onTap: () => _pickFile("PAN"),
            ),
            _buildUploadTile(
              label: "Address Proof",
              fileName: _addressFileName ?? 'No file selected',
              onTap: () => _pickFile("ADDRESS"),
            ),
            _buildUploadTile(
              label: "GST Certificate",
              fileName: _gstFileName ?? 'No file selected',
              onTap: () => _pickFile("GST"),
              isOptional: true,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _submitKYC,
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
            ),
          ],
        ),
      ),
    );
  }
}
