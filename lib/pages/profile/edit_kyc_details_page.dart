import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_vendor_app/common/common_layout.dart';

class EditKYCPage extends StatefulWidget {
  const EditKYCPage({super.key});

  @override
  State<EditKYCPage> createState() => _EditKYCPageState();
}

class _EditKYCPageState extends State<EditKYCPage> {
  String? _panFileName = "pan_card.jpg";
  String? _addressFileName = "address_proof.pdf";
  String? _gstFileName = "No file selected";

  Future<void> _pickFile(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final name = result.files.first.name;
      setState(() {
        if (docType == "PAN") {
          _panFileName = name;
        } else if (docType == "ADDRESS") {
          _addressFileName = name;
        } else if (docType == "GST") {
          _gstFileName = name;
        }
      });
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

            // Upload fields
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
                    onPressed: () => context.pop(),
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
