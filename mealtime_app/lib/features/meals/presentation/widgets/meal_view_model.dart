import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:flutter/foundation.dart';

@immutable
class MealViewModel {
  final Meal meal;
  final String formattedScheduledAt;
  final bool isOverdue;

  /// A view model for a Meal that pre-calculates display-specific values.
  ///
  /// This optimization prevents expensive calculations inside the `build` method
  /// of widgets. By passing a consistent `now` DateTime, we ensure that all
  /// time-sensitive calculations (like `isOverdue` and relative date formatting)
  /// are based on the same point in time, avoiding inconsistencies and
  /// redundant calls to `DateTime.now()`.
  MealViewModel({required this.meal, required DateTime now})
      : formattedScheduledAt = _formatDateTime(meal.scheduledAt, now),
        isOverdue = meal.status == MealStatus.scheduled &&
            meal.scheduledAt.isBefore(now);

  static String _formatDateTime(DateTime dateTime, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateText;
    if (mealDate == today) {
      dateText = 'Hoje';
    } else if (mealDate == today.add(const Duration(days: 1))) {
      dateText = 'Amanhã';
    } else if (mealDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Ontem';
    } else {
      const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      const months = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      // Note: `dateTime.weekday` is 1 for Monday, 7 for Sunday.
      // `weekdays` list is 0-indexed starting with Sunday.
      dateText =
          '${weekdays[dateTime.weekday % 7]}, ${dateTime.day} ${months[dateTime.month - 1]}';
    }

    final timeText =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$dateText às $timeText';
  }
}
