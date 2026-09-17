import 'package:flutter/material.dart';

import 'package:lays_rating/models/user_photo.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/photo_service.dart';
import 'package:lays_rating/utils/date_formatter.dart';

import 'likers_sheet.dart';

// Полноэкранный просмотр фотографий с листанием, лайками и удалением.
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
  late final PageController _pageController;
  late int _currentIndex;
  late List<UserPhoto> _photos;
  int? _loadingPhotoId;
  bool _wasDeleted = false;
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _photos = List.from(widget.photos);
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.pop(context, _wasDeleted);
  }

  Future<void> _handleLike() async {
    final photo = _photos[_currentIndex];
    if (_loadingPhotoId == photo.id) return;

    setState(() => _loadingPhotoId = photo.id);

    try {
      final response = await PhotoService.toggleLike(photo.id);
      if (mounted) {
        final updated = photo.copyWith(
          isLiked: response.isLiked,
          likesCount: response.likesCount,
        );
        setState(() {
          _photos[_currentIndex] = updated;
          _loadingPhotoId = null;
        });
        widget.onPhotoUpdated(updated);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingPhotoId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось поставить лайк')),
        );
      }
    }
  }

  void _showLikers() {
    final photo = _photos[_currentIndex];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (context) => LikersSheet(photoId: photo.id),
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
                      await PhotoService.deletePhoto(_photos[_currentIndex].id);
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

                      _pageController.jumpToPage(_currentIndex);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Не удалось удалить')),
                        );
                      }
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
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
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Нет фото', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final currentPhoto = _photos[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _close,
          ),
          title: Text(
            '${_currentIndex + 1} / ${_photos.length}',
            style: const TextStyle(fontSize: 16),
          ),
          centerTitle: true,
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
        ),
        body: Listener(
          onPointerDown: (event) {
            _dragStart = event.position;
          },
          onPointerUp: (event) {
            if (_dragStart != null) {
              final delta = event.position - _dragStart!;
              if (delta.dy.abs() > 100 && delta.dy.abs() > delta.dx.abs()) {
                _close();
              }
              _dragStart = null;
            }
          },
          child: PageView.builder(
            controller: _pageController,
            itemCount: _photos.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 3.0,
                child: Image.network(
                  '${AuthService.baseUrl}/photos/images/${photo.imagePath}',
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: Container(
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
                      currentPhoto.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: currentPhoto.isLiked ? Colors.red : Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${currentPhoto.likesCount}',
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
                    formatShortDate(currentPhoto.createdAt),
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
        ),
      ),
    );
  }
}