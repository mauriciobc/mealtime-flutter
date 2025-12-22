import 'package:equatable/equatable.dart';

const List<String> _weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
const List<String> _months = [
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

enum MealStatus { scheduled, completed, skipped, cancelled }

enum MealType { breakfast, lunch, dinner, snack }

class Meal extends Equatable {
  final String id;
  final String catId;
  final String homeId;
  final MealType type;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final DateTime? skippedAt;
  final MealStatus status;
  final String? notes;
  final double? amount; // em gramas
  final String? foodType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String absoluteDateString;
  final String timeString;

  Meal({
    required this.id,
    required this.catId,
    required this.homeId,
    required this.type,
    required this.scheduledAt,
    this.completedAt,
    this.skippedAt,
    required this.status,
    this.notes,
    this.amount,
    this.foodType,
    required this.createdAt,
    required this.updatedAt,
  })  : absoluteDateString = _formatAbsoluteDate(scheduledAt),
        timeString = _formatTime(scheduledAt);

  @override
  List<Object?> get props => [
    id,
    catId,
    homeId,
    type,
    scheduledAt,
    completedAt,
    skippedAt,
    status,
    notes,
    amount,
    foodType,
    createdAt,
    updatedAt,
        absoluteDateString,
        timeString,
  ];

  Meal copyWith({
    String? id,
    String? catId,
    String? homeId,
    MealType? type,
    DateTime? scheduledAt,
    DateTime? completedAt,
    DateTime? skippedAt,
    MealStatus? status,
    String? notes,
    double? amount,
    String? foodType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      homeId: homeId ?? this.homeId,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      skippedAt: skippedAt ?? this.skippedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      foodType: foodType ?? this.foodType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    return status == MealStatus.scheduled &&
        scheduledAt.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  String get typeDisplayName {
    switch (type) {
      case MealType.breakfast:
        return 'Café da manhã';
      case MealType.lunch:
        return 'Almoço';
      case MealType.dinner:
        return 'Jantar';
      case MealType.snack:
        return 'Lanche';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case MealStatus.scheduled:
        return 'Agendada';
      case MealStatus.completed:
        return 'Concluída';
      case MealStatus.skipped:
        return 'Pulada';
      case MealStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get formattedScheduledAt {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate =
        DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);

    if (mealDate == today) {
      return 'Hoje às $timeString';
    } else if (mealDate == today.add(const Duration(days: 1))) {
      return 'Amanhã às $timeString';
    } else if (mealDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem às $timeString';
    } else {
      return '$absoluteDateString às $timeString';
    }
  }
}

String _formatAbsoluteDate(DateTime date) {
  final mealDate = DateTime(date.year, date.month, date.day);
  return '${_weekdays[mealDate.weekday % 7]}, ${mealDate.day} ${_months[mealDate.month - 1]}';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
