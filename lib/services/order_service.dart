// services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static Future<List> fetchOrders(String token) async {
    final url = Uri.parse(
      'http://localhost:3000/api/MobileApp/vendor/order-management',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded['data'];
      return data;
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
