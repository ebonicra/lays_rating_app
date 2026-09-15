import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chip.dart';
import 'auth_service.dart';


class ChipService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<List<LaysChip>> fetchChips({List<String>? categories}) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    Uri uri = Uri.parse("$baseUrl/chips");

    if (categories != null && categories.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        'categories': categories,
      });
    }

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load chips");
    }

    final List data = jsonDecode(response.body);
    return data.map((json) => LaysChip.fromJson(json)).toList();
  }

  static Future<LaysChip> fetchChipById(int chipId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("$baseUrl/chips/$chipId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Чипс не найден");
    }

    return LaysChip.fromJson(jsonDecode(response.body));
  }

  static Future<void> updateChip({
    required int chipId,
    String? name,
    String? category,
    String? description,
    String? collection,
    int? releaseYear,
    String? country,
    bool? available,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (category != null) body['category'] = category;
    if (description != null) body['description'] = description;
    if (collection != null) body['collection'] = collection;
    if (releaseYear != null) body['release_year'] = releaseYear;
    if (country != null) body['country'] = country;
    if (available != null) body['available'] = available;

    final response = await http.put(
      Uri.parse('$baseUrl/admin/chips/$chipId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Не удалось обновить чипсы');
      } catch (_) {
        throw Exception('Не удалось обновить чипсы');
      }
    }
  }

  static Future<String> uploadChipImage({
    required int chipId,
    required String filePath,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('$baseUrl/admin/chips/$chipId/image');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить картинку');
    }

    final data = jsonDecode(await response.stream.bytesToString());
    return data['image_path'];
  }

  static Future<int> createChip({
    required String name,
    required String category,
    required String description,
    String? imagePath,
    String? collection,
    String? country,
    int? releaseYear,
    bool available = true,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/admin/chips');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Обязательные
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['description'] = description;
    request.fields['available'] = available.toString();

    // Опциональные
    if (collection != null) request.fields['collection'] = collection;
    if (country != null) request.fields['country'] = country;
    if (releaseYear != null) {
      request.fields['release_year'] = releaseYear.toString();
    }

    // Картинка — только если есть
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      print('❌ Ошибка создания чипсов: $body');
      throw Exception('Не удалось создать чипсы');
    }

    final data = jsonDecode(body);
    return data['id'];
  }
}