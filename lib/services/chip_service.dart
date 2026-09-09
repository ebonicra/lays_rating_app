import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chip.dart';
import 'auth_service.dart';


class ChipService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<List<LaysChip>> fetchChips({List<String>? categories}) async {
    String url = "$baseUrl/chips/";

    final token = await AuthService.getToken();
    if(categories != null && categories.isNotEmpty) {
      final params = categories
          .map((e) => "categories=$e")
          .join("&");

      url = "$url?$params";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );
    if(response.statusCode != 200){
      throw Exception(
        "Failed to load chips",
      );
    }

    final List data = jsonDecode(response.body);
    return data
        .map((json) => LaysChip.fromJson(json))
        .toList();
  }

  static Future<LaysChip> fetchChipById(int chipId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/chips/$chipId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if(response.statusCode != 200){
      throw Exception("Чипс не найден");
    }

    final json = jsonDecode(response.body);
    return LaysChip.fromJson(json);
  }

  static Future<void> updateChip({
    required int chipId,
    String? name,
    String? category,
    String? description,
    String? imagePath,
    String? collection,
    int? releaseYear,
    String? country,
    bool? available,
  }) async {
    final token = await AuthService.getToken();
    
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (category != null) body['category'] = category;
    if (description != null) body['description'] = description;
    if (imagePath != null) body['image_path'] = imagePath;
    if (collection != null) body['collection'] = collection;
    if (releaseYear != null) body['release_year'] = releaseYear;
    if (country != null) body['country'] = country;
    if (available != null) body['available'] = available;

    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}/admin/chips/$chipId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось обновить чипсы: ${response.statusCode}');
    }
  }

  static Future<String> uploadChipImage({
    required int chipId,
    required String filePath,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/admin/chips/$chipId/image');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final data = jsonDecode(await response.stream.bytesToString());
      return data['image_path'];
    } else {
      throw Exception('Не удалось загрузить картинку');
    }
  }


  static Future<int> createChip({
    required String name,
    required String category,
    required String description,
    String? imagePath,
    required String collection,
    required String country,
    required int releaseYear,
    required bool available,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final body = {
      'name': name,
      'category': category,
      'description': description,
      'image_path': imagePath ?? '',
      'collection': collection,
      'country': country,
      'release_year': releaseYear,
      'available': available,
    };

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/admin/chips'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Не удалось создать чипсы');
    }
  }
}