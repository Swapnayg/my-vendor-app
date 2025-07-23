import 'package:flutter/material.dart';
import '/models/product.dart'; // assume Product model exists

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Product image
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.images.isNotEmpty
                      ? product.images[0].url
                      : 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 📛 Product name
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // 💰 Product price
            Text(
              '₹${product.price.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.green.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
