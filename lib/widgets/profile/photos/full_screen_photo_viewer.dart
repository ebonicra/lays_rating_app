import 'package:flutter/material.dart';

import 'package:lays_rating/models/user_photo.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/photo_service.dart';
import 'package:lays_rating/utils/date_formatter.dart';
import 'package:lays_rating/widgets/common/full_screen_gallery.dart';

import 'likers_sheet.dart';

/// Полноэкранный просмотр фотографий профиля.
class FullScreenPhotoViewer extends StatefulWidget {
  const FullScreenPhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.isMyProfile,
    required this.onPhotoUpdated,
  });

  final List<UserPhoto> photos;
  final int initialIndex;
  final bool isMyProfile;

  /// Вызывается при изменении лайка — родитель обновляет свою копию.
  final ValueChanged<UserPhoto> onPhotoUpdated;

  @override
  State<FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<FullScreenPhotoViewer> {
  late List<UserPhoto> _photos;
  late int _currentIndex;
  int? _loadingPhotoId;
  bool _wasDeleted = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _photos = List.from(widget.photos);
  }

  UserPhoto get _currentPhoto => _photos[_currentIndex];

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
        const SnackBar(content: Text('Не удалось поставить лайк')),
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
        maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                  onPressed: () async {
                    try {
                      await PhotoService.deletePhoto(_currentPhoto.id);
                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      setState(() {
                        _photos.removeAt(_currentIndex);
                        _wasDeleted = true;

                        if (_photos.isEmpty) {
                          _close();
                          return;
                        }
                        _currentIndex =
                            _currentIndex.clamp(0, _photos.length - 1);
                      });
                    } catch (e) {
                      debugPrint('FullScreenPhotoViewer delete error: $e');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Не удалось удалить')),
                      );
                    }
                  },
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

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageUrls = _photos
        .map((p) => '${AuthService.baseUrl}/photos/images/${p.imagePath}')
        .toList();

    return FullScreenGallery(
      imageUrls: imageUrls,
      initialIndex: _currentIndex,
      onClose: _close,
      actions: [
        IconButton(
          onPressed: _showLikers,
          icon: const Icon(Icons.people_rounded),
          tooltip: 'Кто лайкнул',
        ),
        if (widget.isMyProfile)
          IconButton(
            onPressed: _showDeleteDialog,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
      bottomBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    final photo = _currentPhoto;
    final colorScheme = Theme.of(context).colorScheme;

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
                  color: Colors.white.withOpacity(0.6),
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