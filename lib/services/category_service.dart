import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/unauthorized_exception.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import 'auth_service.dart';

class CategoryService {
  final AuthService _authService = AuthService();
  static const String _baseUrl = 'http://127.0.0.1:8000/api/v1';

  Future<ProductListResponse> getProductsByCategory(int categoryId, {int page = 1, int retryCount = 0}) async {
    const maxRetries = 2;

    try {
      final headers = await _authService.getAuthHeaders();
      
      final url = Uri.parse('$_baseUrl/products/category/$categoryId')
          .replace(queryParameters: {'page': page.toString()});
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => http.Response(
              jsonEncode({'error': 'Request timed out'}),
              408,
              headers: {'Content-Type': 'application/json'},
            ),
          );
      stopwatch.stop();

      if (response.statusCode == 401) {
        if (retryCount >= maxRetries) {
          await _authService.logout();
          throw const UnauthorizedException(
            'Your session has expired. Please log in again.',
          );
        }

        final refreshed = await _authService.refreshToken();
        if (refreshed) {
          return getProductsByCategory(categoryId, page: page, retryCount: retryCount + 1);
        } else {
          throw const UnauthorizedException('Failed to refresh token');
        }
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ProductListResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load products for category $categoryId');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category>> getCategories({int retryCount = 0}) async {
    const maxRetries = 2;

    try {
      final headers = await _authService.getAuthHeaders();
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(Uri.parse('$_baseUrl/categories'), headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => http.Response(
              jsonEncode({'error': 'Request timed out'}),
              408,
              headers: {'Content-Type': 'application/json'},
            ),
          );
      stopwatch.stop();

      // Handle unauthorized (401) - token might be invalid
      if (response.statusCode == 401) {
        if (retryCount >= maxRetries) {
          await _authService.logout();
          throw const UnauthorizedException(
            'Your session has expired. Please log in again.',
          );
        }

        final refreshed = await _authService.refreshToken();

        if (refreshed) {
          return getCategories(retryCount: retryCount + 1);
        } else {
          await _authService.logout();
          throw const UnauthorizedException(
            'Your session has expired. Please log in again.',
          );
        }
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData;
        try {
          responseData = json.decode(utf8.decode(response.bodyBytes));
        } catch (e) {
          throw Exception('Error processing server response');
        }

        if (responseData['success'] == true) {
          try {
            final List<dynamic> data = responseData['data'] ?? [];
            final categories = data
                .map<Category>((json) => Category.fromJson(json))
                .toList();
            return categories;
          } catch (parseError) {
            throw Exception('Error processing category data');
          }
        } else {
          final errorMsg = responseData['message'] ?? 'Unknown server error';
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg =
            'Server error: ${response.statusCode} ${response.reasonPhrase}';
        throw Exception(errorMsg);
      }
    } on TimeoutException {
      throw TimeoutException(
        'Request timed out. Please check your internet connection.',
      );
    } on FormatException {
      rethrow;
    } on UnauthorizedException {
      rethrow; // Already handled, just rethrow
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to load categories. Please try again.');
    }
  }

  Future<ProductListResponse> getCategoryProducts(
    int categoryId, {
    int page = 1,
  }) async {
    try {
      // Get auth headers with token
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/categories/$categoryId/hierarchy?page=$page'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        
        if (responseData['success'] == true) {
          final productsData = responseData['data']['products'];
          return ProductListResponse.fromJson(productsData);
        } else {
          throw Exception(
            'Failed to load products: ${responseData['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load products. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}
