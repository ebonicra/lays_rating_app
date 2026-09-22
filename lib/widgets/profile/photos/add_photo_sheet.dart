import 'package:flutter/material.dart';

// Источник фото для загрузки.
enum AddPhotoSource { gallery, camera }

// Шит с выбором источника фото.
class AddPhotoSheet {
  AddPhotoSheet._();

  static Future<AddPhotoSource?> show(BuildContext context) {
    return showModalBottomSheet<AddPhotoSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _AddPhotoSheetContent(),
    );
  }
}

class _AddPhotoSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Выбрать из галереи'),
            onTap: () => Navigator.pop(context, AddPhotoSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Сделать фото'),
            onTap: () => Navigator.pop(context, AddPhotoSource.camera),
          ),
        ],
      ),
    );
  }
}