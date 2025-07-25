import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String token;
  final String baseUrl =
      'https://vendor-admin-portal.netlify.app/api/MobileApp';

  ApiService({required this.token});

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('GET $endpoint failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('GET $endpoint error: $e');
      return null;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('POST $endpoint failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('POST $endpoint error: $e');
      return null;
    }
  }
}
