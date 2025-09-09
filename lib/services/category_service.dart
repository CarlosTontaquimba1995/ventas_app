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
      print('Getting auth headers...');
      final headers = await _authService.getAuthHeaders();
      
      final url = Uri.parse('$_baseUrl/products/category/$categoryId')
          .replace(queryParameters: {'page': page.toString()});
      
      print('=== REQUEST DETAILS ===');
      print('Full URL: $url');
      print('Headers: $headers');
      print('Method: GET');
      print('Category ID: $categoryId');
      print('Page: $page');
      print('======================');
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

      print('Request completed in ${stopwatch.elapsedMilliseconds}ms');
      print('=== RESPONSE DETAILS ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body:');
      print(response.body);
      print('========================');
      
      // Try to parse the response to see its structure
      try {
        final responseData = jsonDecode(response.body);
        print('Parsed Response:');
        print('Keys in response: ${responseData.keys.toList()}');
        if (responseData.containsKey('data')) {
          print('Data type: ${responseData['data'].runtimeType}');
          if (responseData['data'] is List) {
            print('Data length: ${responseData['data'].length}');
            if (responseData['data'].isNotEmpty) {
              print('First item in data: ${responseData['data'][0]}');
            }
          }
        }
      } catch (e) {
        print('Error parsing response: $e');
      }

      if (response.statusCode == 401) {
        if (retryCount >= maxRetries) {
          print('Max retry attempts reached. Logging out...');
          await _authService.logout();
          throw const UnauthorizedException(
            'Your session has expired. Please log in again.',
          );
        }

        print('Attempt ${retryCount + 1} of $maxRetries - Refreshing token...');
        final refreshed = await _authService.refreshToken();
        if (refreshed) {
          return getProductsByCategory(categoryId, page: page, retryCount: retryCount + 1);
        } else {
          throw const UnauthorizedException('Failed to refresh token');
        }
      }

      if (response.statusCode == 200) {
        print('Raw API Response: ${response.body}');
        final responseData = jsonDecode(response.body);
        print('Parsed Response Data: $responseData');
        return ProductListResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load products for category $categoryId');
      }
    } catch (e) {
      print('Error in getProductsByCategory: $e');
      rethrow;
    }
  }

  Future<List<Category>> getCategories({int retryCount = 0}) async {
    const maxRetries = 2;

    try {
      print('Getting auth headers...');
      final headers = await _authService.getAuthHeaders();
      print('Headers: ${headers.keys.join(', ')}');

      print('Fetching categories from: $_baseUrl/categories');
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

      print('Request completed in ${stopwatch.elapsedMilliseconds}ms');
      print('Response status: ${response.statusCode}');

      // Handle unauthorized (401) - token might be invalid
      if (response.statusCode == 401) {
        if (retryCount >= maxRetries) {
          print('Max retry attempts reached. Logging out...');
          await _authService.logout();
          throw const UnauthorizedException(
            'Your session has expired. Please log in again.',
          );
        }

        print('Attempt ${retryCount + 1} of $maxRetries - Refreshing token...');
        final refreshed = await _authService.refreshToken();

        if (refreshed) {
          print('Token refresh successful, retrying request...');
          return getCategories(retryCount: retryCount + 1);
        } else {
          print('Token refresh failed - logging out');
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
          print('Error decoding response: $e');
          throw Exception('Error processing server response');
        }

        if (responseData['success'] == true) {
          try {
            final List<dynamic> data = responseData['data'] ?? [];
            final categories = data
                .map<Category>((json) => Category.fromJson(json))
                .toList();
            print('Successfully parsed ${categories.length} categories');
            return categories;
          } catch (parseError) {
            print('Error parsing category data: $parseError');
            print('Problematic data: ${responseData['data']}');
            throw Exception('Error processing category data');
          }
        } else {
          final errorMsg = responseData['message'] ?? 'Unknown server error';
          print('API Error: $errorMsg');
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg =
            'Server error: ${response.statusCode} ${response.reasonPhrase}';
        print(errorMsg);
        throw Exception(errorMsg);
      }
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
      throw TimeoutException(
        'Request timed out. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      print('Format error: $e');
      rethrow;
    } on UnauthorizedException {
      rethrow; // Already handled, just rethrow
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error. Please check your internet connection.');
    } catch (e, stackTrace) {
      print('Unexpected error in getCategories:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
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
