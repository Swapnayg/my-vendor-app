import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:my_vendor_app/models/ticket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/common/common_layout.dart';

const Map<TicketType, String> vendorTicketTypeLabels = {
  TicketType.PAYMENT_ISSUE: 'Payment Issue',
  TicketType.PRODUCT_LISTING_ISSUE: 'Product Listing Issue',
  TicketType.INVENTORY_UPDATE_ISSUE: 'Inventory Update Issue',
  TicketType.SHIPPING_ISSUE: 'Shipping Issue',
};

class RaiseTicketPage extends StatefulWidget {
  const RaiseTicketPage({super.key});

  @override
  State<RaiseTicketPage> createState() => _RaiseTicketPageState();
}

class _RaiseTicketPageState extends State<RaiseTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  TicketType? _selectedTicketType;
  PlatformFile? _pickedFile; // Used for both mobile and web
  bool _loading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: kIsWeb,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
        });
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick file')));
    }
  }

  Future<String?> _uploadToCloudinary(PlatformFile file) async {
    const cloudName = 'dhas7vy3k';
    const uploadPreset = 'vendors';
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    try {
      if (file.bytes == null && file.path == null) {
        return null;
      }

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
            contentType: MediaType('application', 'octet-stream'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResp = json.decode(responseData);
        return jsonResp['secure_url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    String? fileUrl;

    if (_pickedFile != null) {
      fileUrl = await _uploadToCloudinary(_pickedFile!);
      if (fileUrl == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('File upload failed')));
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final requestBody = {
      'subject': _subjectController.text.trim(),
      'message': _descriptionController.text.trim(),
      'type': _selectedTicketType.toString(),
      'fileUrl': fileUrl,
    };

    try {
      final res = await http.post(
        Uri.parse(
          'http://localhost:3000/api/MobileApp/vendor/ticket-submission',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      setState(() => _loading = false);

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket submitted successfully')),
        );
        context.go('/tickets');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${res.body}')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/tickets'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Submit a Support Ticket',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Subject', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: "Briefly describe your issue",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Subject required'
                            : null,
              ),
              const SizedBox(height: 16),

              const Text('Category', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              DropdownButtonFormField<TicketType>(
                value: _selectedTicketType,
                onChanged:
                    (value) => setState(() => _selectedTicketType = value),
                items:
                    vendorTicketTypeLabels.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Ticket Type',
                ),
              ),
              const SizedBox(height: 16),

              const Text('Description', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Provide detailed information about the issue...',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Description required'
                            : null,
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: _pickFile,
                child: DottedBorderUpload(fileSelected: _pickedFile != null),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A5CFA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _loading ? 'Submitting...' : 'Submit Ticket',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedBorderUpload extends StatelessWidget {
  final bool fileSelected;
  const DottedBorderUpload({super.key, required this.fileSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDCFFD)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 40,
            color: Color(0xFF7A5CFA),
          ),
          const SizedBox(height: 10),
          Text(
            fileSelected
                ? 'File selected successfully!'
                : 'Drag & drop or click to upload',
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          const Text(
            'Max file size: 10MB (PNG, JPG, PDF)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
