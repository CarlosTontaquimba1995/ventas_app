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

  // Save the token and user data
  Future<bool> _saveAuthData(String token, String email, {Map<String, dynamic>? userData}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save the token and email
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userEmailKey, email);
      
      // Save additional user data if provided
      if (userData != null) {
        await prefs.setString('user_id', userData['id']?.toString() ?? '');
        await prefs.setString('user_name', userData['name']?.toString() ?? '');
        await prefs.setString('user_role', userData['role']?.toString() ?? 'customer');
        await prefs.setString('user_phone', userData['phone']?.toString() ?? '');
        await prefs.setString('user_address', userData['address']?.toString() ?? '');
      }
      
      return true;
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      return false;
    }
  }

  // Clear all stored auth data
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all auth-related keys
      await prefs.remove(_tokenKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      await prefs.remove('user_phone');
      await prefs.remove('user_address');
      
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

  // Get auth headers with token for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
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
          'Accept': 'application/json',
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
      
      if ((response.statusCode == 201 || response.statusCode == 200) && responseData['success'] == true) {
        // Save the token and user data on successful registration
        if (responseData['data']?['access_token'] != null) {
          final userData = responseData['data']?['user'];
          await _saveAuthData(
            responseData['data']['access_token'], 
            email,
            userData: userData is Map ? Map<String, dynamic>.from(userData) : null,
          );
        }
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'data': responseData['data'],
          'user': responseData['data']?['user'] ?? {},
        };
      } else {
        // Handle error response
        final errorMessage = responseData['message'] ?? 
          (responseData['error']?.toString() ?? 'Registration failed');
        
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
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Save the token and user data on successful login
        if (responseData['data']?['access_token'] != null) {
          // Save the token, email, and user data
          final userData = responseData['data']?['user'];
          final saved = await _saveAuthData(
            responseData['data']['access_token'], 
            email,
            userData: userData is Map ? Map<String, dynamic>.from(userData) : null,
          );
          if (!saved) {
            debugPrint('Warning: Could not save auth data to persistent storage');
          }
          
          // Return the complete response data including user information
          return {
            'success': true,
            'message': responseData['message'] ?? 'Inicio de sesión exitoso',
            'data': responseData['data'],
            'user': responseData['data']?['user'] ?? {},
          };
        }
        
        // If we get here, there was an issue with the response format
        return {
          'success': false,
          'message': 'Formato de respuesta inesperado del servidor',
          'statusCode': response.statusCode,
        };
      } else {
        // Handle error response
        final errorMessage = responseData['message'] ?? 
          (responseData['error']?.toString() ?? 'Error de autenticación');
        
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
