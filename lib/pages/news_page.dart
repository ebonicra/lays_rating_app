import 'package:flutter/material.dart';
import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/services/news_service.dart';
import 'package:lays_rating/services/auth_service.dart';

import '../widgets/news_card.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsItem>? _news;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final news = await NewsService.getFeed();
      if (mounted) {
        setState(() {
          _news = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить новости';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadNews,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (_news == null || _news!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'Пока нет новостей',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Подпишись на друзей, чтобы видеть их активность',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _news!.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // ← отступы по бокам
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade300.withOpacity(0.5),
          ),
        ),
        itemBuilder: (context, index) {
          return NewsCard(
            item: _news![index],
            onDeleted: _loadNews,
            onVoted: (updatedItem) {
              setState(() {
                final idx = _news!.indexWhere((n) => n.id == updatedItem.id);
                if (idx != -1) {
                  _news![idx] = updatedItem;
                }
              });
            },
          );
        },
      ),
    );
  }
}

