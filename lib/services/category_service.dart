import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import 'auth_service.dart';

class CategoryService {
  final AuthService _authService = AuthService();
  static const String _baseUrl = 'http://127.0.0.1:8000/api/v1';

  Future<List<Category>> getCategories() async {
    try {
      // Get auth headers with token
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Category.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load categories: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
