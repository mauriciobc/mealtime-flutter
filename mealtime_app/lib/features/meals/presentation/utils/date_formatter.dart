const List<String> weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
const List<String> months = [
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

String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();
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
    dateText =
        '${weekdays[mealDate.weekday % 7]}, ${mealDate.day} ${months[mealDate.month - 1]}';
  }

  final timeText =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  return '$dateText às $timeText';
}
