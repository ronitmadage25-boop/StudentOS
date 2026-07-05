/// Extension on [DateTime] providing convenient formatting helpers.
extension DateTimeExtension on DateTime {
  /// Returns a human-readable relative date string.
  ///
  /// Example output: "Today", "Tomorrow", "5 Days Left".
  String get relativeDaysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(year, month, day);
    final difference = target.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 0) return '${-difference} Days Ago';
    return '$difference Days Left';
  }

  /// Returns a short date string, e.g. "5 Jul".
  String get shortDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$day ${months[month - 1]}';
  }
}
