import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_rating_with_user.dart';
import 'package:lays_rating/pages/profile/public_profile_page.dart';
import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/widgets/common/rating_badge.dart';
import 'package:lays_rating/widgets/common/user_avatar.dart';

/// Bottom sheet со списком пользователей, оценивших чипс.
class ChipRatingsSheet extends StatefulWidget {
  const ChipRatingsSheet({
    super.key,
    required this.chipId,
  });

  final int chipId;

  static Future<void> show(BuildContext context, int chipId) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChipRatingsSheet(chipId: chipId),
    );
  }

  @override
  State<ChipRatingsSheet> createState() => _ChipRatingsSheetState();
}

class _ChipRatingsSheetState extends State<ChipRatingsSheet> {
  late final Future<List<ChipRatingWithUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChipService.getRatings(widget.chipId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<ChipRatingWithUser>>(
          future: _future,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                Expanded(child: _buildBody(context, snapshot)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.star_rounded, size: 24, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'Оценки',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<ChipRatingWithUser>> snapshot,
  ) {
    final theme = Theme.of(context);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Text(
          'Не удалось загрузить оценки',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final ratings = snapshot.data;
    if (ratings == null || ratings.isEmpty) {
      return Center(
        child: Text(
          'Пока никто не оценил',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final item = ratings[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: UserAvatar(
            displayName: item.user.displayName,
            avatarUrl: item.user.avatarUrl,
            radius: 20,
          ),
          title: Text(
            item.user.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('@${item.user.username}'),
          trailing: RatingBadge(rating: item.rating),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfilePage(userId: item.user.id),
              ),
            );
          },
        );
      },
    );
  }
}