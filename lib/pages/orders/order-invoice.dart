import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';

class InvoicePage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String source;

  const InvoicePage({super.key, required this.order, required this.source});

  @override
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'SHIPPED':
        return Colors.blue;
      case 'DELIVERED':
        return Colors.green;
      case 'RETURNED':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List items = order['items'];
    final total = items.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item['price'] as double) * (item['quantity'] as int),
    );

    final customer = order['customer'];
    final formattedDate = DateFormat.yMMMMd().format(
      DateTime.tryParse(order['createdAt'] ?? '') ?? DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (source == 'management') {
              context.go('/orders/management');
            } else {
              context.go('/orders/latest-orders');
            }
          },
        ),
        title: const Text('Invoice Details'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID and Date Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order ID',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                '${order['orderId']}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Date',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(formattedDate),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payment Status:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order['status'],
                              ), // dynamic background
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order['status'], // assuming this holds values like 'PENDING', etc.
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '${order['orderId']}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(formattedDate),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payment Status:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['payment']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order['payment'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(
                  'Customer Details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('Name', style: Theme.of(context).textTheme.labelMedium),
                Text('${customer['name']}'),
                Text('Email', style: Theme.of(context).textTheme.labelMedium),
                Text('${customer['email']}'),
                Text('Phone', style: Theme.of(context).textTheme.labelMedium),
                Text('${customer['phone']}'),
                const SizedBox(height: 16),
                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...items.map<Widget>((item) {
                  return ListTile(
                    leading: Image.asset(
                      item['image'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name']),
                    subtitle: Text('${item['quantity']} x ₹${item['price']}'),
                    trailing: Text(
                      '₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                    ),
                  );
                }),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: ₹${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _downloadInvoicePDF,
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      'Download Invoice',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Button background
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadInvoicePDF() async {
    final font = await PdfGoogleFonts.robotoRegular();

    final pdf = pw.Document();
    final List items = order['items'];
    final total = items.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item['price'] as double) * (item['quantity'] as int),
    );

    final customer = order['customer'];
    final formattedDate = DateFormat.yMMMMd().format(
      DateTime.tryParse(order['createdAt'] ?? '') ?? DateTime.now(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${order['vendor']['businessName']}',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Order ID:', style: pw.TextStyle(font: font)),
                pw.Text(
                  '#${order['orderId']}',
                  style: pw.TextStyle(font: font),
                ),
                pw.Text('Date:', style: pw.TextStyle(font: font)),
                pw.Text(formattedDate, style: pw.TextStyle(font: font)),
                pw.Text('Payment Status:', style: pw.TextStyle(font: font)),
                pw.Text('${order['payment']}', style: pw.TextStyle(font: font)),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Customer Details:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
                pw.Text(
                  'Name: ${customer['name']}',
                  style: pw.TextStyle(font: font),
                ),
                pw.Text(
                  'Email: ${customer['email']}',
                  style: pw.TextStyle(font: font),
                ),
                pw.Text(
                  'Phone: ${customer['phone']}',
                  style: pw.TextStyle(font: font),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Items Summary:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['Item', 'Qty', 'Price', 'Total'],
                  data:
                      items.map((item) {
                        final price = item['price'] as double;
                        final qty = item['quantity'] as int;
                        return [
                          item['name'],
                          '$qty',
                          '₹${price.toStringAsFixed(2)}',
                          '₹${(price * qty).toStringAsFixed(2)}',
                        ];
                      }).toList(),
                  cellStyle: pw.TextStyle(font: font),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total: ₹${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
