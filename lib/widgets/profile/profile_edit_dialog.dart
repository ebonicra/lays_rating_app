import 'dart:io';

import 'package:flutter/material.dart';

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/avatar_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/utils/initials.dart';

// Диалог редактирования профиля: аватар, имя, username.
class ProfileEditDialog extends StatefulWidget {
  const ProfileEditDialog({
    super.key,
    required this.user,
  });

  final User user;

  static Future<bool?> show(BuildContext context, User user) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ProfileEditDialog(user: user),
    );
  }

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;

  /// Текущее изображение аватара для отображения.
  /// null — нет аватара, показываем инициал.
  ImageProvider? _avatarImage;

  /// Путь к локально выбранному файлу (если пользователь выбрал новый).
  /// null — либо не менял, либо выбрал удаление.
  String? _localAvatarPath;

  /// Был ли удалён аватар (пользователь нажал «Удалить фото»).
  bool _avatarDeleted = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _usernameController = TextEditingController(text: widget.user.username);
    _avatarImage = _initialAvatarImage(widget.user.avatarUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  ImageProvider? _initialAvatarImage(String? avatarUrl) {
    if (avatarUrl == null) return null;
    if (avatarUrl.startsWith('/')) {
      return NetworkImage('${AuthService.baseUrl}$avatarUrl');
    }
    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    }
    return null;
  }

  Future<void> _pickPhoto() async {
    final path = await AvatarService.pickLocalAvatar();
    if (path == null) return;
    setState(() {
      _localAvatarPath = path;
      _avatarImage = FileImage(File(path));
      _avatarDeleted = false;
    });
  }

  void _deletePhoto() {
    setState(() {
      _localAvatarPath = null;
      _avatarImage = null;
      _avatarDeleted = true;
    });
  }

  void _showAvatarSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Выбрать фото'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _pickPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Удалить фото'),
              onTap: () {
                Navigator.pop(sheetContext);
                _deletePhoto();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните имя и username')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Аватар
      if (_localAvatarPath != null) {
        await AvatarService.uploadLocalAvatar(_localAvatarPath!);
      } else if (_avatarDeleted && widget.user.avatarUrl != null) {
        await AvatarService.deleteAvatar();
      }

      // 2. Имя и username
      await UserService.updateProfile(
        displayName: name,
        username: username,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text(
        'Редактировать профиль',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Аватар
          Center(
            child: GestureDetector(
              onTap: _isSaving ? null : _showAvatarSheet,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _avatarImage,
                  child: _avatarImage == null
                      ? Text(
                          initialOf(widget.user.displayName),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Имя
          TextField(
            controller: _nameController,
            enabled: !_isSaving,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Имя',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Username
          TextField(
            controller: _usernameController,
            enabled: !_isSaving,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}