// Возвращает правильную форму слова для числа [count].
String pluralize(
  int count, {
  required String one,
  required String few,
  required String many,
}) {
  if (count % 10 == 1 && count % 100 != 11) return one;
  if ([2, 3, 4].contains(count % 10) &&
      ![12, 13, 14].contains(count % 100)) {
    return few;
  }
  return many;
}