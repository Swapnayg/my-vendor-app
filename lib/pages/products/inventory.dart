import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/models/product_image.dart';
import '/models/product.dart';
import '/common/common_layout.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  List<Product> products = [
    Product(
      id: 1,
      name: 'Smart Kettle Pro',
      description: '',
      price: 200,
      basePrice: 180,
      taxRate: 10,
      stock: 10,
      vendorId: 1,
      status: ProductStatus.approved,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: [
        ProductImage(
          url: 'assets/images/upload.png',
          id: 1,
          productId: 1,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: 2,
      name: 'Ergonomic Desk Chair',
      description: '',
      price: 150,
      basePrice: 130,
      taxRate: 12,
      stock: 0,
      vendorId: 1,
      status: ProductStatus.approved,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: [
        ProductImage(
          url: 'assets/images/upload.png',
          id: 2,
          productId: 2,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: 3,
      name: 'Noise-Cancelling Headphones',
      description: '',
      price: 299.99,
      basePrice: 250,
      taxRate: 15,
      stock: 5,
      vendorId: 1,
      status: ProductStatus.approved,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: [
        ProductImage(
          url: 'assets/images/upload.png',
          id: 3,
          productId: 3,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: 4,
      name: 'Smart Home Hub',
      description: '',
      price: 89.50,
      basePrice: 75,
      taxRate: 8,
      stock: 25,
      vendorId: 1,
      status: ProductStatus.approved,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: [
        ProductImage(
          url: 'assets/images/upload.png',
          id: 4,
          productId: 4,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: 5,
      name: 'Portable Espresso Maker',
      description: '',
      price: 75,
      basePrice: 65,
      taxRate: 10,
      stock: 1,
      vendorId: 1,
      status: ProductStatus.approved,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: [
        ProductImage(
          url: 'assets/images/upload.png',
          id: 5,
          productId: 5,
          createdAt: DateTime.now(),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts =
        products.where((p) {
          final query = searchQuery.toLowerCase();
          return p.name.toLowerCase().contains(query) ||
              p.price.toString().contains(query) ||
              p.stock.toString().contains(query);
        }).toList();

    return CommonLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Custom AppBar Area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              const Text(
                'Product Inventory',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const CircleAvatar(
                backgroundImage: NetworkImage("https://via.placeholder.com/40"),
                radius: 18,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search products...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.filter_alt_outlined),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Product List
          Expanded(
            child: ListView.separated(
              itemCount: filteredProducts.length,
              padding: const EdgeInsets.only(bottom: 24),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return ProductCard(product: filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              product.images.isNotEmpty ? product.images[0].url : '',
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  "In Stock: ${product.stock}",
                  style: TextStyle(
                    fontSize: 13,
                    color: product.stock > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              context.go('/products/inventory-stock', extra: product);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }
}
