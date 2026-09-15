import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'auth_service.dart';


class AvatarService {
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

  static Future<bool> uploadAvatar() async {
    final path = await pickLocalAvatar();
    if (path == null) return false;

    await uploadLocalAvatar(path);
    return true;
  }

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
}