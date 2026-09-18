import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Универсальный полноэкранный просмотр изображений с листанием и зумом
class FullScreenGallery extends StatefulWidget {
  const FullScreenGallery({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    this.actions = const [],
    this.bottomBar,
    this.onClose,
    this.enableSwipeToDismiss = true,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final List<Widget> actions;
  final Widget? bottomBar;
  final VoidCallback? onClose;
  final bool enableSwipeToDismiss;

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late final PageController _controller;
  late int _currentIndex;
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.pop(context);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragStart = event.position;
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_dragStart == null) return;

    final delta = event.position - _dragStart!;
    if (delta.dy.abs() > 100 && delta.dy.abs() > delta.dx.abs()) {
      _close();
    }
    _dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Нет изображений', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final gallery = PhotoViewGallery.builder(
      pageController: _controller,
      itemCount: widget.imageUrls.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(widget.imageUrls[index]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
        );
      },
      loadingBuilder: (context, event) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _close,
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        actions: widget.actions,
      ),
      body: widget.enableSwipeToDismiss
          ? Listener(
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerUp,
              child: gallery,
            )
          : gallery,
      bottomNavigationBar: widget.bottomBar,
    );
  }
}