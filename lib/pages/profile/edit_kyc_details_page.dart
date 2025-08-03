import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditKYCPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const EditKYCPage({super.key, this.data});

  @override
  State<EditKYCPage> createState() => _EditKYCPageState();
}

class _EditKYCPageState extends State<EditKYCPage> {
  PlatformFile? _panFile;
  PlatformFile? _addressFile;
  PlatformFile? _gstFile;

  String? _panFileName = "No file selected";
  String? _addressFileName = "No file selected";
  String? _gstFileName = "No file selected";

  String? _existingPanUrl;
  String? _existingAddressUrl;
  String? _existingGstUrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingKyc();
  }

  Future<void> _loadExistingKyc() async {
    if (widget.data != null && widget.data!['kycDocuments'] != null) {
      final kycDocs = widget.data!['kycDocuments'] as List<dynamic>;
      for (final doc in kycDocs) {
        final type = doc['type'];
        final fileUrl = doc['fileUrl'];
        if (type == 'panCard') {
          _existingPanUrl = fileUrl;
          _panFileName = 'Existing PAN uploaded';
        } else if (type == 'addressProof') {
          _existingAddressUrl = fileUrl;
          _addressFileName = 'Existing Address uploaded';
        } else if (type == 'gstCertificate') {
          _existingGstUrl = fileUrl;
          _gstFileName = 'Existing GST uploaded';
        }
      }
    }
  }

  Future<String> _uploadToCloudinary(PlatformFile file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/dhas7vy3k/image/upload',
    );
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = 'vendors';

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody);
    return json['secure_url'];
  }

  Future<void> _pickFile(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: kIsWeb,
    );

    if (result != null && result.files.isNotEmpty) {
      final pickedFile = result.files.first;
      setState(() {
        if (docType == "panCard") {
          _panFile = pickedFile;
          _panFileName = pickedFile.name;
        } else if (docType == "addressProof") {
          _addressFile = pickedFile;
          _addressFileName = pickedFile.name;
        } else if (docType == "gstCertificate") {
          _gstFile = pickedFile;
          _gstFileName = pickedFile.name;
        }
      });
    }
  }

  Future<void> _submitKYC() async {
    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    if (_panFile == null && _existingPanUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PAN Card is required"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    if (_addressFile == null && _existingAddressUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Address Proof is required"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    try {
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
        Uri.parse('http://localhost:3000/api/MobileApp/vendor/kyc-details'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'panCardFile': panUrl,
          'addressProofFile': addressUrl,
          'gstCertificateFile': gstUrl,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("KYC updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update KYC (${response.statusCode})"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Upload new KYC documents below:",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      _buildUploadTile(
                        label: "PAN Card",
                        fileName: _panFileName ?? 'No file selected',
                        onTap: () => _pickFile("panCard"),
                      ),
                      _buildUploadTile(
                        label: "Address Proof",
                        fileName: _addressFileName ?? 'No file selected',
                        onTap: () => _pickFile("addressProof"),
                      ),
                      _buildUploadTile(
                        label: "GST Certificate",
                        fileName: _gstFileName ?? 'No file selected',
                        onTap: () => _pickFile("gstCertificate"),
                        isOptional: true,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitKYC,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child:
                                  _isSubmitting
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text("Save Changes"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isSubmitting
                                      ? null
                                      : () => context.go('/profile'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
