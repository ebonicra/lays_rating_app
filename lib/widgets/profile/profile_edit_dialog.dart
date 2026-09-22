import 'dart:io';

import 'package:flutter/material.dart';

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/avatar_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/utils/initials.dart';

/// Диалог редактирования профиля: аватар, имя, username.
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
  ImageProvider? _avatarImage;
  String? _localAvatarPath;
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
    if (avatarUrl.startsWith('http')) return NetworkImage(avatarUrl);
    return NetworkImage('${AuthService.baseUrl}$avatarUrl');
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
    final colorScheme = Theme.of(context).colorScheme;

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
              leading: Icon(Icons.delete, color: colorScheme.error),
              title: Text(
                'Удалить фото',
                style: TextStyle(color: colorScheme.error),
              ),
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
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Заполните имя и username')
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_localAvatarPath != null) {
        await AvatarService.uploadLocalAvatar(_localAvatarPath!);
      } else if (_avatarDeleted && widget.user.avatarUrl != null) {
        await AvatarService.deleteAvatar();
      }

      await UserService.updateProfile(
        displayName: name,
        username: username,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('ProfileEditDialog._save error: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);

      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message)),
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
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  radius: 60,
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
          TextFormField(
            controller: _nameController,
            enabled: !_isSaving,
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: 'Имя',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Введите имя';
              if (value.length > 20) return 'Максимум 20 символов';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _usernameController,
            enabled: !_isSaving,
            decoration: InputDecoration(
              labelText: 'Username',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Введите username';
              if (value.length > 20) return 'Максимум 20 символов';
              return null;
            },
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed:
                    _isSaving ? null : () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Сохранить',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}