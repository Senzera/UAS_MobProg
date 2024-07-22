import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://healthylifes.c1.is/api';

  static Future<String?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return null; // No error message if successful
      } else {
        final data = json.decode(response.body);
        print('Parsed response: $data');
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          return errors.values.first.join(', ');
        } else if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        } else {
          return 'Failed to register. Please try again.';
        }
      }
    } catch (e) {
      print('Error during registration: $e');
      return 'Failed to register. Please try again.';
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']); // Save the token
        return data['access_token'];
      } else {
        final data = json.decode(response.body);
        print('Parsed response: $data');
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        } else {
          return 'Failed to login. Status code: ${response.statusCode}';
        }
      }
    } catch (e) {
      print('Error during login: $e');
      return 'Failed to login. Please try again.';
    }
  }

  static Future<String?> saveReminder(String description, String time) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/reminders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'description': description,
          'time': time,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return null; // No error message if successful
      } else {
        final data = json.decode(response.body);
        print('Parsed response: $data');
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          return errors.values.first.join(', ');
        } else if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        } else {
          return 'Failed to save reminder.';
        }
      }
    } catch (e) {
      print('Error during saving reminder: $e');
      return 'Failed to save reminder. Please try again.';
    }
  }
}
