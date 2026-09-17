import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/constants/photo_constants.dart';
import 'package:lays_rating/models/user_photo.dart';
import 'package:lays_rating/services/photo_service.dart';

import 'package:lays_rating/widgets/profile/photos/add_photo_card.dart';
import 'package:lays_rating/widgets/profile/photos/full_screen_photo_viewer.dart';
import 'package:lays_rating/widgets/profile/photos/likers_sheet.dart';
import 'package:lays_rating/widgets/profile/photos/photo_card.dart';


class ProfilePhotoCarousel extends StatefulWidget {
  const ProfilePhotoCarousel({
    super.key,
    required this.userId,
    required this.isMyProfile,
  });

  final int userId;
  final bool isMyProfile;

  @override
  State<ProfilePhotoCarousel> createState() => _ProfilePhotoCarouselState();
}

class _ProfilePhotoCarouselState extends State<ProfilePhotoCarousel> {
  List<UserPhoto>? _photos;
  bool _isLoading = true;
  int? _loadingPhotoId;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);

    try {
      final response = await PhotoService.getUserPhotos(widget.userId);
      if (!mounted) return;
      setState(() {
        _photos = response.photos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('loadPhotos error: $e');
      if (!mounted) return;
      setState(() {
        _photos = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLike(UserPhoto photo) async {
    if (_loadingPhotoId == photo.id) return;

    setState(() => _loadingPhotoId = photo.id);

    try {
      final response = await PhotoService.toggleLike(photo.id);
      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingPhotoId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось поставить лайк')),
      );
    }
  }

  void _showLikers(UserPhoto photo) {
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
        final image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 1080,
          maxHeight: 1080,
        );
        if (image != null) images = [image];
      } else {
        images = await picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1080,
          maxHeight: 1080,
        );
      }

      if (images.isEmpty) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Загружаю ${images.length} фото...')),
      );

      int uploaded = 0;
      for (final image in images) {
        try {
          await PhotoService.uploadPhoto(image.path);
          uploaded++;
        } catch (e) {
          debugPrint('uploadPhoto error: $e');
        }
      }

      if (!mounted) return;
      await _loadPhotos();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('Загружено $uploaded из ${images.length}')),
      );
    } catch (e) {
      debugPrint('pickAndUpload error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _openFullScreen(int index) async {
    final wasDeleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoViewer(
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
        ),
      ),
    );

    if (wasDeleted == true && mounted) {
      await _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_photos == null || _photos!.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: PhotoConstants.cardSize,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _photos!.length + (widget.isMyProfile ? 1 : 0),
        itemBuilder: (context, index) {
          if (widget.isMyProfile && index == _photos!.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AddPhotoCard(onTap: _showAddPhotoSheet),
            );
          }

          final photo = _photos![index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PhotoConstants.cardPadding,
            ),
            child: PhotoCard(
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

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!widget.isMyProfile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: PhotoConstants.cardSize,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
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
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Нет фото',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: PhotoConstants.cardSize,
        width: double.infinity,
        child: AddPhotoCard(
          onTap: _showAddPhotoSheet,
          fullWidth: true,
        ),
      ),
    );
  }
}