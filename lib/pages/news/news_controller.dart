import 'package:flutter/foundation.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/services/news_service.dart';

// Состояние и логика страницы новостей.
class NewsController extends ChangeNotifier {
  NewsController();

  List<NewsItem>? _news;
  bool _isLoading = true;      // первая загрузка
  bool _isRefreshing = false;  // pull-to-refresh
  String? _error;

  List<NewsItem>? get news => _news;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  /// Первая загрузка (когда страница только открылась).
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _fetch();
    _isLoading = false;
    notifyListeners();
  }

  /// Pull-to-refresh: не сбрасывает список, не переключает экран в лоадер.
  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    await _fetch();
    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> _fetch() async {
    try {
      _news = await NewsService.getFeed();
      _error = null;
    } catch (e) {
      debugPrint('NewsController._fetch error: $e');
      _error = 'Не удалось загрузить новости';
    }
  }

  void updateItem(NewsItem updated) {
    final list = _news;
    if (list == null) return;

    final idx = list.indexWhere((n) => n.id == updated.id);
    if (idx == -1) return;

    list[idx] = updated;
    notifyListeners();
  }

  void removeItem(int id) {
    _news?.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}