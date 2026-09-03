import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';

class AvatarService {
  
  /// Загрузить аватарку на сервер
  static Future<String?> uploadAvatar() async {
    // 1. Выбрать картинку
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (image == null) return null;

    // 2. Отправить на сервер
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/users/me/avatar');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      return image.path; // возвращаем локальный путь для предпросмотра
    } else {
      throw Exception('Ошибка загрузки аватарки');
    }
  }

  /// Получить URL аватарки
  static Future<String?> getAvatarUrl() async {
    // Можно получать из UserService.currentUser
    return null; // Будет заполнено при загрузке профиля
  }

  /// Удалить аватарку с сервера
  static Future<void> deleteAvatar() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/users/me/avatar'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка удаления аватарки');
    }
  }


  static Future<String?> pickLocalAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 500,
      maxHeight: 500,
    );
    return image?.path;
  }

  /// Загрузить конкретный локальный файл
  static Future<void> uploadLocalAvatar(String filePath) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/users/me/avatar');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки аватарки');
    }
  }
}