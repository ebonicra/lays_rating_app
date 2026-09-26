enum FeedbackType {
  bug('bug', 'Ошибка', '🐞'),
  suggestion('suggestion', 'Предложение', '💡'),
  complaint('complaint', 'Жалоба', '⚠️'),
  thanks('thanks', 'Благодарность', '❤️'),
  question('question', 'Вопрос', '❓'),
  other('other', 'Другое', '✉️');

  const FeedbackType(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;
}