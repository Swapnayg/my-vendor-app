import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';

class KYCPreviewPage extends StatelessWidget {
  final String title;
  final String url;

  const KYCPreviewPage({super.key, required this.title, required this.url});

  bool get isPDF => url.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body:
          isPDF
              ? SfPdfViewer.network(url)
              : kIsWeb
              ? InteractiveViewer(child: Image.network(url))
              : PhotoView(
                imageProvider: NetworkImage(url),
                backgroundDecoration: const BoxDecoration(color: Colors.white),
              ),
    );
  }
}
