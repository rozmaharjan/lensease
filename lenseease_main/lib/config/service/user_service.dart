import 'dart:convert';


import 'package:http/http.dart' as http;
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';

class UserService {
  final String baseUrl;
  final String deleteUrl;
  final String editUrl;

  final SecureStorage secureStorage;

  UserService({
    required this.baseUrl,
    required this.deleteUrl,
    required this.editUrl,
    required this.secureStorage,
  });

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    try {
      final token = await secureStorage.readToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('userProfile')) {
          return responseData['userProfile'];
        } else {
          throw Exception('userProfile key not found in response');
        }
      } else {
        throw Exception(
            'Failed to load user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Failed to load user data');
    }
  }

  Future<void> updateUserData(
      String userId, Map<String, dynamic> userData) async {
    try {
      final token = await secureStorage.readToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.put(
        Uri.parse('$editUrl/$userId'), // Corrected URL formation
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        print('User data updated successfully');
      } else {
        print(
            'Failed to update user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update user data');
      }
    } catch (e) {
      print('Failed to update user data in frontend. $e');
      throw Exception('Failed to update user data in frontend.');
    }
  }

  Future<void> deleteAccount(String userId) async {
    try {
      final token = await secureStorage.readToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response =
          await http.delete(Uri.parse('$deleteUrl/$userId'), headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        await secureStorage.deleteToken();
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      print('Error deleting account: $e');
      throw Exception('Failed to delete account');
    }
  }
}
