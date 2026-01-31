import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_storage.dart';

class UserProfileService {
  static Future<String?> uploadProfilePicture(File imageFile) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final uri = ApiConfig.uri('/api/user/profile/picture');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final imageUrl = data['profileImageUrl'] as String;

      // Update stored user data with new image URL
      final userData = await TokenStorage.getUserData();
      if (userData != null) {
        userData['profileImageUrl'] = imageUrl;
        // We need to save this back - let's update TokenStorage
      }

      return imageUrl;
    } else {
      final errorMessage = response.body.isNotEmpty ? response.body : 'Greska prilikom uploada slike';
      throw Exception(errorMessage);
    }
  }

  static Future<void> deleteProfilePicture() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.delete(
      ApiConfig.uri('/api/user/profile/picture'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Greska prilikom brisanja slike');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.get(
      ApiConfig.uri('/api/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else if (response.statusCode == 404) {
      throw Exception('Profil nije pronađen');
    } else {
      throw Exception('Greska prilikom ucitavanja profila');
    }
  }
}
