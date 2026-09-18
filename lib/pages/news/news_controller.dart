import 'package:flutter/foundation.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/services/news_service.dart';

// Состояние и логика страницы новостей.
class NewsController extends ChangeNotifier {
  NewsController();

  List<NewsItem>? _news;
  bool _isLoading = true;
  String? _error;

  List<NewsItem>? get news => _news;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _news = await NewsService.getFeed();
    } catch (e) {
      debugPrint('NewsController.load error: $e');
      _error = 'Не удалось загрузить новости';
    } finally {
      _isLoading = false;
      notifyListeners();
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