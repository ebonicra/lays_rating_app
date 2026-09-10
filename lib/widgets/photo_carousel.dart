import 'package:flutter/material.dart';
import 'package:lays_rating/models/user_photo.dart';
import 'package:lays_rating/services/photo_service.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/pages/public_profile_page.dart';
import 'package:lays_rating/constants/photo_constants.dart';


import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';

class PhotoCarousel extends StatefulWidget {
  final int userId;
  final bool isMyProfile;
  

  const PhotoCarousel({
    super.key,
    required this.userId,
    required this.isMyProfile,
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  List<UserPhoto>? _photos;
  bool _isLoading = true;
  int? _loadingPhotoId;
  final ScrollController _scrollController = ScrollController();

  @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    void _scrollToIndex(int index) {
      if (!_scrollController.hasClients) return;
      
      const itemWidth = 208.0; // 200 + 2*4 (padding)
      final target = index * itemWidth - 100; // центрируем
      
      _scrollController.animateTo(
        target.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }


  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);

    try {
      final response = await PhotoService.getUserPhotos(widget.userId);
      if (mounted) {
        setState(() {
          _photos = response.photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _photos = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLike(UserPhoto photo) async {
    if (_loadingPhotoId == photo.id) return;
    
    setState(() => _loadingPhotoId = photo.id);

    try {
      final response = await PhotoService.toggleLike(photo.id);
      
      if (mounted) {
        setState(() {
          final index = _photos!.indexWhere((p) => p.id == photo.id);
          if (index != -1) {
            _photos![index] = _photos![index].copyWith(
              isLiked: response.isLiked,
              likesCount: response.likesCount,
            );
          }
          _loadingPhotoId = null;
        });
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

  Future<void> _showLikers(UserPhoto photo) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (context) => _LikersSheet(photoId: photo.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_photos == null || _photos!.isEmpty) {
      return _buildEmptyState(theme);
    }

    return SizedBox(
      height: PhotoConstants.cardSize,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        // +1 если свой профиль
        itemCount: _photos!.length + (widget.isMyProfile ? 1 : 0),
        itemBuilder: (context, index) {
          // Последняя карточка — кнопка добавить
          if (widget.isMyProfile && index == _photos!.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _AddPhotoCard(onTap: _showAddPhotoSheet),
            );
          }

          final photo = _photos![index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: PhotoConstants.cardPadding),
            child: _PhotoCard(
              photo: photo,
              onTap: () => _openFullScreen(index),
              onLikeTap: () => _handleLike(photo),
              onCountTap: () => _showLikers(photo),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    // Для чужого профиля — простая заглушка
    if (!widget.isMyProfile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4), // ← как у кнопки добавления
        child: SizedBox(
          height: PhotoConstants.cardSize,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 18, // ← увеличили иконку
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Нет фото',
                  style: TextStyle(
                    fontSize: 12, // ← увеличили шрифт
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Для своего профиля — кнопка добавить на всю ширину
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: PhotoConstants.cardSize,
        width: double.infinity,
        child: _AddPhotoCardFullWidth(onTap: _showAddPhotoSheet),
      ),
    );
  }

  void _showAddPhotoSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Выбрать из галереи'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndUpload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Сделать фото'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndUpload(fromCamera: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpload({bool fromCamera = false}) async {
    final picker = ImagePicker();

    try {
      List<XFile> images = [];

      if (fromCamera) {
        // Одно фото с камеры
        final image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 1080,
          maxHeight: 1080,
        );
        if (image != null) images = [image];
      } else {
        // Несколько фото из галереи
        images = await picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1080,
          maxHeight: 1080,
        );
      }

      if (images.isEmpty) return;

      // Показываем прогресс
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Загружаю ${images.length} фото...')),
      //   );
      // }

      // Загружаем каждое фото
      int uploaded = 0;
      for (final image in images) {
        try {
          await PhotoService.uploadPhoto(image.path);
          uploaded++;
        } catch (e) {
          // if (mounted) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('Ошибка: $e')),
          //   );
          // }
        }
      }

      // Обновляем список
      if (mounted) {
        await _loadPhotos();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('✅ Загружено $uploaded из ${images.length}')),
        // );
      }
    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Ошибка: $e')),
      //   );
      // }
    }
  }



  void _openFullScreen(int index) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenPhotoViewer(
          photos: _photos!,
          initialIndex: index,
          isMyProfile: widget.isMyProfile,
          onPhotoUpdated: (updatedPhoto) {
            setState(() {
              final idx = _photos!.indexWhere((p) => p.id == updatedPhoto.id);
              if (idx != -1) {
                _photos![idx] = updatedPhoto;
              }
            });
          },
          onPhotoDeleted: _loadPhotos,
        ),
      ),
    );

    if (result == null) return;

    final wasDeleted = result['deleted'] as bool? ?? false;
    final returnIndex = result['index'] as int? ?? 0;

    // Обновляем и скроллим только если было удаление
    if (wasDeleted) {
      await _loadPhotos();

      if (mounted && _photos != null && returnIndex < _photos!.length) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToIndex(returnIndex);
        });
      }
    }
  }
}

class _PhotoCard extends StatelessWidget {
  final UserPhoto photo;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCountTap;

  const _PhotoCard({
    required this.photo,
    required this.onTap,
    required this.onLikeTap,
    required this.onCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Image.network(
              '${AuthService.baseUrl}/photos/images/${photo.imagePath}',
              width: PhotoConstants.cardSize,
              height: PhotoConstants.cardSize,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: PhotoConstants.cardSize,
                  height: PhotoConstants.cardSize,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: PhotoConstants.cardSize,
                  height: PhotoConstants.cardSize,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          // Лайки внизу
          Positioned(
            bottom: 4,
            left: 4,
            child: GestureDetector(
              onTap: onLikeTap,
              onLongPress: onCountTap,
              behavior: HitTestBehavior.opaque, // ← перехватывает тапы
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ← чуть больше область
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      photo.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      size: 16,
                      color: photo.isLiked ? Colors.red : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${photo.likesCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _AddPhotoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: PhotoConstants.cardSize,
        height: PhotoConstants.cardSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Добавить фото',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPhotoCardFullWidth extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoCardFullWidth({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавить фото',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikersSheet extends StatefulWidget {
  final int photoId;

  const _LikersSheet({required this.photoId});

  @override
  State<_LikersSheet> createState() => _LikersSheetState();
}

class _LikersSheetState extends State<_LikersSheet> {
  List<PhotoAuthor>? _users;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikers();
  }

  Future<void> _loadLikers() async {
    try {
      final response = await PhotoService.getLikers(widget.photoId);
      if (mounted) {
        setState(() {
          _users = response.users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _users = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 6),
              Text(
                'Лайкнули',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Список
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_users == null || _users!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Пока никто не лайкнул',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _users!.length,
                itemBuilder: (context, index) {
                  final user = _users![index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage('${AuthService.baseUrl}${user.avatarUrl}')
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.displayName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    title: Text(
                      user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('@${user.username}'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicProfilePage(userId: user.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}



class _FullScreenPhotoViewer extends StatefulWidget {
  final List<UserPhoto> photos;
  final int initialIndex;
  final bool isMyProfile;
  final ValueChanged<UserPhoto> onPhotoUpdated;
  final VoidCallback onPhotoDeleted;

  const _FullScreenPhotoViewer({
    required this.photos,
    required this.initialIndex,
    required this.isMyProfile,
    required this.onPhotoUpdated,
    required this.onPhotoDeleted,
  });

  @override
  State<_FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<_FullScreenPhotoViewer> {
  late PageController _pageController;
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
    Navigator.pop(context, {
      'index': _currentIndex,
      'deleted': _wasDeleted,
    });
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
      builder: (context) => _LikersSheet(photoId: photo.id),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фото?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    try {
                      await PhotoService.deletePhoto(_photos[_currentIndex].id);
                      if (mounted) {
                        Navigator.pop(context); // закрываем диалог
                        setState(() {
                          _photos.removeAt(_currentIndex);
                          _wasDeleted = true;
                          if (_photos.isEmpty) {
                            Navigator.pop(context, {
                              'index': 0,
                              'deleted': true,
                            });
                            return;
                          }
                          _currentIndex = _currentIndex.clamp(0, _photos.length - 1);
                        });
                        _pageController.jumpToPage(_currentIndex);
                      }
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
            // Список лайкнувших
            IconButton(
              onPressed: _showLikers,
              icon: const Icon(Icons.people_rounded),
              tooltip: 'Кто лайкнул',
            ),
            // Удалить — только для своих фото
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
              // Свайп вверх/вниз если движение больше 100px и по вертикали больше чем по горизонтали
              if (delta.dy.abs() > 100 && delta.dy.abs() > delta.dx.abs()) {
                _close();
              }
              _dragStart = null;
            }
          },
          child: PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: _photos.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            builder: (context, index) {
              final photo = _photos[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(
                  '${AuthService.baseUrl}/photos/images/${photo.imagePath}',
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: photo.id),
              );
            },
            loadingBuilder: (context, event) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: Colors.black,
          child: Stack(
            children: [
              // Сердечко — тап = лайк, долгое = список
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
                    _formatFullDate(currentPhoto.createdAt),
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