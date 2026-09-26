import 'package:flutter/material.dart';

import 'package:lays_rating/widgets/common/reaction_button.dart';

class NewsReactionsBar extends StatelessWidget {
  const NewsReactionsBar({
    super.key,
    required this.isLiked,
    required this.isDisliked,
    required this.likesCount,
    required this.dislikesCount,
    required this.isLoading,
    required this.onLike,
    required this.onDislike,
    this.onShowLikes,
    this.onShowDislikes,
  });

  final bool isLiked;
  final bool isDisliked;
  final int likesCount;
  final int dislikesCount;
  final bool isLoading;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback? onShowLikes;
  final VoidCallback? onShowDislikes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ReactionButton(
            icon: Icons.favorite_outline_rounded,
            activeIcon: Icons.favorite_rounded,
            count: likesCount,
            isActive: isLiked,
            activeColor: Colors.red,
            isLoading: isLoading,
            onTap: onLike,
            onLongPress: onShowLikes,
          ),
          const SizedBox(width: 6),
          ReactionButton(
            icon: Icons.heart_broken_outlined,
            activeIcon: Icons.heart_broken_rounded,
            count: dislikesCount,
            isActive: isDisliked,
            activeColor: Colors.brown,
            isLoading: isLoading,
            onTap: onDislike,
            onLongPress: onShowDislikes,
          ),
        ],
      ),
    );
  }
}