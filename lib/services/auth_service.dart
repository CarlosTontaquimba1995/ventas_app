import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthService {
  //static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  
  // For testing with physical device, use your computer's IP address
  static const String baseUrl = 'http://10.2.0.35:8000/api/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';

  // Get the stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      // Handle any potential errors when accessing SharedPreferences
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  // Get the stored user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Save the token and user email
  Future<bool> _saveAuthData(String token, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userEmailKey, email);
      return true;
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      return false;
    }
  }

  // Clear the stored auth data
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userEmailKey);
      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Get auth headers with token
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Save the token and email on successful registration
        if (responseData['token'] != null) {
          await _saveAuthData(responseData['token'], email);
        }
        return {
          'success': true,
          'message': 'Registration successful',
          'data': responseData,
        };
      } else {
        // Return error response
        final errorMessage = responseData['message'] ?? 
          (responseData['error'] ?? 'Registration failed');
        
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': errorMessage,
          'errors': responseData['errors'] ?? {},
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } catch (e) {
      debugPrint('Registration error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200) {
        // Save the token and email on successful login
        if (responseData['token'] != null) {
          final saved = await _saveAuthData(responseData['token'], email);
          if (!saved) {
            debugPrint('Warning: Could not save auth data to persistent storage');
          }
        }
        return responseData;
      } else {
        // Return error response instead of throwing
        final errorMessage = responseData['message'] ?? 
          (responseData['error'] ?? 'Error de autenticación');
        
        // Return error response with status code and message
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': errorMessage,
          'error': {
            'code': response.statusCode,
            'message': errorMessage,
          },
        };
      }
    } on http.ClientException {
      return {
        'success': false,
        'statusCode': 0,
        'message': 'Error de conexión. Verifique su conexión a internet.',
        'error': {
          'code': 0,
          'message': 'Error de conexión',
        },
      };
    } on FormatException {
      return {
        'success': false,
        'statusCode': 0,
        'message': 'Error en el formato de la respuesta del servidor.',
        'error': {
          'code': 0,
          'message': 'Error de formato',
        },
      };
    } on TimeoutException {
      return {
        'success': false,
        'statusCode': 408,
        'message': 'Tiempo de espera agotado. Por favor, intente de nuevo.',
        'error': {
          'code': 408,
          'message': 'Tiempo de espera agotado',
        },
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'message': 'Ocurrió un error inesperado. Por favor, intente de nuevo.',
        'error': {
          'code': 0,
          'message': 'Error inesperado',
        },
      };
    }
  }
}
