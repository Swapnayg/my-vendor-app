import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/common/common_layout.dart';

class RaiseTicketPage extends StatelessWidget {
  const RaiseTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            TextField(
              decoration: InputDecoration(
                hintText: "Briefly describe your issue",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Category', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: 'Technical Support',
              items: const [
                DropdownMenuItem(
                  value: 'Technical Support',
                  child: Text('Technical Support'),
                ),
                DropdownMenuItem(value: 'Billing', child: Text('Billing')),
                DropdownMenuItem(value: 'General', child: Text('General')),
              ],
              onChanged: (value) {},
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Description', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Provide detailed information about the issue, including steps to reproduce...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const DottedBorderUpload(),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Submit ticket logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5CFA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Submit Ticket',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedBorderUpload extends StatelessWidget {
  const DottedBorderUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFDDCFFD),
          style: BorderStyle.solid,
        ),
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
          const Text(
            'Drag & drop files or click to upload',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          const Text(
            'Max file size: 10MB (PNG, JPG, PDF)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              // file picker
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF7A5CFA)),
            ),
            child: const Text('Browse Files'),
          ),
        ],
      ),
    );
  }
}
