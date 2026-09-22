import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/constants/photo_constants.dart';
import 'package:lays_rating/models/photo/photo.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/services/photo_service.dart';

import 'package:lays_rating/widgets/profile/photos/add_photo_sheet.dart';
import 'package:lays_rating/widgets/profile/photos/empty_photo_card.dart';
import 'package:lays_rating/widgets/profile/photos/full_screen_photo_viewer.dart';
import 'package:lays_rating/widgets/profile/photos/likers_sheet.dart';
import 'package:lays_rating/widgets/profile/photos/photo_card.dart';


/// Карусель фото пользователя
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
  List<Photo>? _photos;
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
      debugPrint('ProfilePhotoCarousel._loadPhotos error: $e');
      if (!mounted) return;
      setState(() {
        _photos = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLike(Photo photo) async {
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
      debugPrint('ProfilePhotoCarousel._handleLike error: $e');
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

  void _showLikers(Photo photo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
      builder: (_) => LikersSheet(photoId: photo.id),
    );
  }

  Future<void> _showAddPhotoSheet() async {
    final source = await AddPhotoSheet.show(context);
    if (source == null || !mounted) return;
    await _pickAndUpload(fromCamera: source == AddPhotoSource.camera);
  }

  Future<void> _pickAndUpload({bool fromCamera = false}) async {
    final picker = ImagePicker();

    try {
      final images = await _pickImages(picker, fromCamera: fromCamera);
      if (images.isEmpty) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Загружаю ${images.length} фото...')
        ),
      );

      final uploaded = await _uploadImages(images);

      if (!mounted) return;
      await _loadPhotos();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Загружено $uploaded из ${images.length}')
        ),
      );
    } catch (e) {
      debugPrint('ProfilePhotoCarousel._pickAndUpload error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось загрузить фото')
        ),
      );
    }
  }

  Future<List<XFile>> _pickImages(
    ImagePicker picker, {
    required bool fromCamera,
  }) async {
    if (fromCamera) {
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      return image != null ? [image] : [];
    }

    return picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1080,
      maxHeight: 1080,
    );
  }

  Future<int> _uploadImages(List<XFile> images) async {
    var uploaded = 0;
    for (final image in images) {
      try {
        await PhotoService.uploadPhoto(image.path);
        uploaded++;
      } catch (e) {
        debugPrint('ProfilePhotoCarousel upload error: $e');
      }
    }
    return uploaded;
  }

  Future<void> _openFullScreen(int index) async {
    final wasDeleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoViewer(
          photos: _photos!,
          initialIndex: index,
          isMyProfile: widget.isMyProfile,
          isAdmin: UserService.currentUser?.isAdmin ?? false,
          onPhotoUpdated: (Photo updatedPhoto) {
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: PhotoConstants.cardSize,
          width: double.infinity,
          child: EmptyPhotoCard(
            icon: widget.isMyProfile
                ? Icons.add_rounded
                : Icons.photo_library_outlined,
            label: widget.isMyProfile ? 'Добавить фото' : 'Нет фото',
            onTap: widget.isMyProfile ? _showAddPhotoSheet : null,
            fullWidth: true,
          ),
        ),
      );
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
              child: EmptyPhotoCard(
                icon: Icons.add_rounded,
                label: 'Добавить фото',
                onTap: _showAddPhotoSheet,
              ),
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
}