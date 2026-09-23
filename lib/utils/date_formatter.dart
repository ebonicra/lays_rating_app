String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  return '$day.$month.$year';
}

String formatRelativeDate(DateTime date) {
  final utcDate = date.isUtc
      ? date
      : DateTime.utc(
          date.year,
          date.month,
          date.day,
          date.hour,
          date.minute,
          date.second,
          date.millisecond,
          date.microsecond,
        );

  final now = DateTime.now().toUtc();
  final diff = now.difference(utcDate);

  if (diff.inMinutes < 1) return 'только что';
  if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
  if (diff.inHours < 24) return '${diff.inHours} ч. назад';
  if (diff.inDays < 7) return '${diff.inDays} д. назад';
  return formatShortDate(date);
}