import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
