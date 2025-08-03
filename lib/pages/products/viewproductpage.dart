import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/models/product.dart';
import '/common/common_layout.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ViewProductPage extends StatelessWidget {
  final Product product;

  const ViewProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String capitalize(String input) {
      if (input.isEmpty) return input;
      return input[0].toUpperCase() + input.substring(1);
    }

    return CommonLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.go('/products/management'),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
                label: const Text(
                  "Back to Products",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18, // Increased text size
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- Product Image ---
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.images.isNotEmpty
                    ? product.images.first.url
                    : "https://via.placeholder.com/300",
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // --- Name & Category ---
            Text(
              product.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                product.category?.name ?? "Uncategorized",
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),

            const SizedBox(height: 16),

            // --- Pricing Details ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoBox(
                  "Price",
                  "₹${product.price.toStringAsFixed(2)}",
                  Colors.green,
                ),
                _infoBox(
                  "Base",
                  "₹${product.basePrice.toStringAsFixed(2)}",
                  Colors.blue,
                ),
                _infoBox(
                  "Tax",
                  "${product.taxRate.toStringAsFixed(2)}%",
                  Colors.orange,
                ),
                _infoBox(
                  "Commission",
                  "${product.defaultCommissionPct?.toStringAsFixed(1) ?? "0"}%",
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Description ---
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 20),

            // --- Compliance Info with Preview ---
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Compliance Info",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),

            if (product.compliance!.isNotEmpty) ...[
              const Text(
                "Compliance Documents",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              for (var compliance in product.compliance!) ...[
                Text("Type: ${compliance.type}"),
                const SizedBox(height: 6),

                if (compliance.fileUrl != null) const SizedBox(height: 10),

                if (compliance.fileUrl != null)
                  _buildDocumentPreview(compliance.fileUrl!),

                const SizedBox(height: 20),
              ],
            ] else
              const Text("No compliances added yet"),

            // --- Rating Summary ---
            _ratingSummary(),

            const SizedBox(height: 20),

            // --- Reviews Section ---
            if (product.reviews.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Reviews",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: product.reviews.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final review = product.reviews[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            capitalize(review.user?.username ?? "Unknown User"),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(width: 10),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(review.rating.toString()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(review.comment ?? ""),

                      const SizedBox(height: 8),
                      if (review.images != null && review.images!.isNotEmpty)
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: review.images!.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  review.images![i] as String,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ] else
              const Text("No reviews yet."),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _ratingSummary() {
    if (product.reviews.isEmpty) return const SizedBox();

    final avgRating =
        product.reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        product.reviews.length;

    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Text(
          "${avgRating.toStringAsFixed(1)} (${product.reviews.length} reviews)",
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDocumentPreview(String url) {
    final isImage =
        url.endsWith(".png") || url.endsWith(".jpg") || url.endsWith(".jpeg");
    final isPdf = url.endsWith(".pdf");

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url, height: 200, fit: BoxFit.contain),
      );
    } else if (isPdf) {
      return Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            label: const Text("Open PDF Document"),
            onPressed: () => _launchURL(url),
          ),
        ),
      );
    } else {
      return const Text("Preview not supported.");
    }
  }
}
