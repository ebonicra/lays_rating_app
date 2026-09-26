import 'package:lays_rating/services/comments_service.dart';
import 'package:lays_rating/services/news_service.dart';
import 'package:lays_rating/widgets/common/reactions_sheet.dart';

/// Лоадер реакций комментария — для ReactionsSheet.
Future<ReactionsData> loadCommentReactions(int commentId) async {
  final data = await CommentsService.getCommentReactions(commentId);
  return ReactionsData(
    likes: data.likes.map((u) => u.toReactionUser()).toList(),
    dislikes: data.dislikes.map((u) => u.toReactionUser()).toList(),
  );
}

/// Лоадер реакций новости — для ReactionsSheet.
Future<ReactionsData> loadNewsReactions(int newsId) async {
  final data = await NewsService.getNewsReactions(newsId);
  return ReactionsData(
    likes: data.likes.map((u) => u.toReactionUser()).toList(),
    dislikes: data.dislikes.map((u) => u.toReactionUser()).toList(),
  );
}