import 'package:flutter/material.dart';

import 'package:lays_rating/models/photo/photo.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/photo_service.dart';
import 'package:lays_rating/utils/date_formatter.dart';
import 'package:lays_rating/widgets/common/full_screen_gallery.dart';

import 'package:lays_rating/widgets/profile/photos/likers_sheet.dart';

/// Полноэкранный просмотр фотографий профиля.
class FullScreenPhotoViewer extends StatefulWidget {
  const FullScreenPhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.isMyProfile,
    required this.isAdmin,
    required this.onPhotoUpdated,
  });

  final List<Photo> photos;
  final int initialIndex;
  final bool isMyProfile;
  final bool isAdmin;

  /// Вызывается при изменении лайка — родитель обновляет свою копию.
  final ValueChanged<Photo> onPhotoUpdated;

  @override
  State<FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<FullScreenPhotoViewer> {
  late List<Photo> _photos;
  late int _currentIndex;
  int? _loadingPhotoId;
  bool _wasDeleted = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _photos = List.from(widget.photos);
  }

  Photo get _currentPhoto => _photos[_currentIndex];

  void _close() {
    Navigator.pop(context, _wasDeleted);
  }

  Future<void> _handleLike() async {
    final photo = _currentPhoto;
    if (_loadingPhotoId == photo.id) return;

    setState(() => _loadingPhotoId = photo.id);

    try {
      final response = await PhotoService.toggleLike(photo.id);
      if (!mounted) return;

      final updated = photo.copyWith(
        isLiked: response.isLiked,
        likesCount: response.likesCount,
      );

      setState(() {
        _photos[_currentIndex] = updated;
        _loadingPhotoId = null;
      });
      widget.onPhotoUpdated(updated);
    } catch (e) {
      debugPrint('FullScreenPhotoViewer._handleLike error: $e');
      if (!mounted) return;
      setState(() => _loadingPhotoId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось поставить лайк')
        ),
      );
    }
  }

  void _showLikers() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
      builder: (_) => LikersSheet(photoId: _currentPhoto.id),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить фото?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () => _deletePhoto(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Удалить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto(BuildContext dialogContext) async {
    final photoId = _currentPhoto.id;

    try {
      await PhotoService.deletePhoto(photoId);
      if (!mounted) return;

      Navigator.pop(dialogContext);

      setState(() {
        _photos.removeAt(_currentIndex);
        _wasDeleted = true;

        if (_photos.isNotEmpty) {
          _currentIndex = _currentIndex.clamp(0, _photos.length - 1);
        }
      });

      if (_photos.isEmpty) {
        _close();
      }
    } catch (e) {
      debugPrint('FullScreenPhotoViewer._deletePhoto error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось удалить')
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageUrls = _photos
        .map((p) => '${AuthService.baseUrl}/photos/images/${p.imagePath}')
        .toList();

    return FullScreenGallery(
      key: ValueKey(_photos.length),
      imageUrls: imageUrls,
      initialIndex: _currentIndex,
      onIndexChanged: (index) => setState(() => _currentIndex = index),
      onClose: _close,
      actions: [
        IconButton(
          onPressed: _showLikers,
          icon: const Icon(Icons.people_rounded),
          tooltip: 'Кто лайкнул',
        ),
        if (widget.isMyProfile || widget.isAdmin)
          IconButton(
            onPressed: _showDeleteDialog,
            icon: Icon(
              Icons.delete_outline,
              color: widget.isMyProfile
                  ? null
                  : Theme.of(context).colorScheme.error,
            ),
          ),
      ],
      bottomBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    final photo = _currentPhoto;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.black,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _handleLike,
            onLongPress: _showLikers,
            child: Row(
              children: [
                Icon(
                  photo.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: photo.isLiked ? Colors.red : Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 6),
                Text(
                  '${photo.likesCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                formatShortDate(photo.createdAt),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}