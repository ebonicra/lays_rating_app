import 'package:flutter/material.dart';

import 'package:lays_rating/models/feedback_item.dart';
import 'package:lays_rating/pages/profile/public_profile_page.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/feedback_service.dart';
import 'package:lays_rating/utils/date_formatter.dart';
import 'package:lays_rating/utils/initials.dart';
import 'package:lays_rating/widgets/profile/admin/feedback/delete_feedback_dialog.dart';
import 'package:lays_rating/widgets/profile/admin/feedback/feedback_images_carusel.dart';


class FeedbackDetailsPage extends StatefulWidget {
  const FeedbackDetailsPage({super.key, required this.item});

  final FeedbackItem item;

  @override
  State<FeedbackDetailsPage> createState() => _FeedbackDetailsPageState();
}

class _FeedbackDetailsPageState extends State<FeedbackDetailsPage> {
  late FeedbackItem _item;
  bool _isMarking = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _toggleRead() async {
    if (_isMarking) return;

    setState(() => _isMarking = true);

    try {
      final updated = await FeedbackService.setReadStatus(
        _item.id,
        isRead: !_item.isRead,
      );
      if (!mounted) return;
      setState(() {
        _item = updated;
        _isMarking = false;
      });
    } catch (e) {
      debugPrint('FeedbackDetailsPage._toggleRead error: $e');
      if (!mounted) return;
      setState(() => _isMarking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось изменить статус'),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await DeleteFeedbackDialog.show(context);
    if (confirmed != true || !mounted) return;

    try {
      await FeedbackService.deleteFeedback(_item.id);
      if (!mounted) return;
      Navigator.pop(context, _item.copyWith(isRead: true));
    } catch (e) {
      debugPrint('FeedbackDetailsPage._delete error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось удалить'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRead = _item.isRead;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _item);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_item.title.isEmpty ? _item.type.label : _item.title),
          actions: [
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Удалить',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Отправитель =====
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PublicProfilePage(userId: _item.user.id),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: _item.user.avatarUrl != null
                          ? NetworkImage(
                              '${AuthService.baseUrl}${_item.user.avatarUrl}',
                            )
                          : null,
                      child: _item.user.avatarUrl == null
                          ? Text(
                              initialOf(
                                _item.user.displayName ?? _item.user.username,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _item.user.displayName ?? _item.user.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '@${_item.user.username}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Справа: «Новое» сверху, дата снизу
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Новое',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '(${formatRelativeDate(_item.createdAt)})',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // ===== Тип =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,   // центрируем содержимое
                child: Text('${_item.type.emoji} ${_item.type.label}'),
              ),
              const SizedBox(height: 30),

              // ===== Заголовок =====
              if (_item.title.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    _item.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // ===== Текст =====
              Text(
                _item.text,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 20),

              // ===== Картинки =====
              if (_item.imagePaths.isNotEmpty) ...[
                FeedbackImagesCarousel(imagePaths: _item.imagePaths),
              ],
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isMarking ? null : _toggleRead,
              icon: _isMarking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isRead
                          ? Icons.mark_email_unread_outlined
                          : Icons.done_all_rounded,
                    ),
              label: Text(
                isRead
                    ? 'Отметить непрочитанным'
                    : 'Отметить прочитанным',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _indentParagraphs(String text) {
    return text
        .split('\n')
        .map((line) => line.trim().isEmpty ? line : '\u00A0\u00A0\u00A0\u00A0$line')
        .join('\n');
  }
}