import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/widgets/news/news_card.dart';

import 'news_controller.dart';


class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final NewsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NewsController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новости')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null && (_controller.news?.isEmpty ?? true)) {
      return _buildError();
    }

    final news = _controller.news;
    if (news == null || news.isEmpty) {
      return _buildEmpty(context);
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: news.length,
        separatorBuilder: (_, __) => _buildSeparator(context),
        itemBuilder: (context, index) {
          final item = news[index];
          return NewsCard(
            item: item,
            onDeleted: () => _controller.removeItem(item.id),
            onVoted: _controller.updateItem,
            onReacted: _controller.updateItem,
          );
        },
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_controller.error!),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _controller.load,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.newspaper, size: 48, color: colorScheme.outline),
                    const SizedBox(height: 12),
                    const Text('Пока нет новостей', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      'Подпишись на друзей, чтобы видеть их активность',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}