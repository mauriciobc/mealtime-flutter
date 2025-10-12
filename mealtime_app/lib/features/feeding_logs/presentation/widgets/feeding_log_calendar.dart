import 'package:flutter/material.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/meal.dart';

class FeedingLogCalendar extends StatefulWidget {
  final List<FeedingLog> feeding_logs;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<FeedingLog>? onFeedingLogSelected;

  const FeedingLogCalendar({
    super.key,
    required this.feeding_logs,
    this.onDateSelected,
    this.onFeedingLogSelected,
  });

  @override
  State<FeedingLogCalendar> createState() => _FeedingLogCalendarState();
}

class _FeedingLogCalendarState extends State<FeedingLogCalendar> {
  DateTime _selectedDate = DateTime.now();
  late PageController _pageController;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(
      initialPage: _getMonthIndex(_currentMonth),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getMonthIndex(DateTime month) {
    final now = DateTime.now();
    return (month.year - now.year) * 12 + (month.month - now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header com navegação
        _buildHeader(),
        const SizedBox(height: 16),

        // Calendário
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              final newMonth = DateTime.now().add(Duration(days: 30 * index));
              setState(() {
                _currentMonth = DateTime(newMonth.year, newMonth.month);
              });
            },
            itemBuilder: (context, index) {
              final month = DateTime.now().add(Duration(days: 30 * index));
              return _buildMonthCalendar(month);
            },
          ),
        ),

        const SizedBox(height: 16),

        // Lista de refeições do dia selecionado
        _buildFeedingLogsForSelectedDate(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          _formatMonth(_currentMonth),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Dias da semana
          Row(
            children: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Dias do mês
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday) {
                  return const SizedBox();
                }

                final day = index - firstWeekday + 1;
                final date = DateTime(month.year, month.month, day);
                final isSelected = _isSameDay(date, _selectedDate);
                final isToday = _isSameDay(date, DateTime.now());
                final hasFeedingLogs = _hasFeedingLogsOnDate(date);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    widget.onDateSelected?.call(date);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : hasFeedingLogs
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : isToday
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                        if (hasFeedingLogs) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingLogsForSelectedDate() {
    final feeding_logsForDate = _getFeedingLogsForDate(_selectedDate);

    if (feeding_logsForDate.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'Nenhuma refeição em ${_formatDate(_selectedDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refeições em ${_formatDate(_selectedDate)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...feeding_logsForDate.map(
              (meal) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildFeedingLogItem(meal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingLogItem(FeedingLog meal) {
    return InkWell(
      onTap: () => widget.onFeedingLogSelected?.call(meal),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildMealTypeIcon(meal.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.typeDisplayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatTime(meal.scheduledAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(meal.status),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeIcon(MealType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case MealType.breakfast:
        iconData = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case MealType.lunch:
        iconData = Icons.wb_sunny_outlined;
        color = Colors.amber;
        break;
      case MealType.dinner:
        iconData = Icons.nightlight_round;
        color = Colors.indigo;
        break;
      case MealType.snack:
        iconData = Icons.cookie;
        color = Colors.brown;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(iconData, color: color, size: 16),
    );
  }

  Widget _buildStatusChip(FeedingLogStatus status) {
    Color color;
    String text;

    switch (status) {
      case FeedingLogStatus.scheduled:
        color = Colors.blue;
        text = 'Agendada';
        break;
      case FeedingLogStatus.completed:
        color = Colors.green;
        text = 'Concluída';
        break;
      case FeedingLogStatus.skipped:
        color = Colors.orange;
        text = 'Pulada';
        break;
      case FeedingLogStatus.cancelled:
        color = Colors.grey;
        text = 'Cancelada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _hasFeedingLogsOnDate(DateTime date) {
    return widget.feeding_logs.any((meal) => _isSameDay(meal.scheduledAt, date));
  }

  List<FeedingLog> _getFeedingLogsForDate(DateTime date) {
    return widget.feeding_logs
        .where((meal) => _isSameDay(meal.scheduledAt, date))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  String _formatMonth(DateTime month) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${months[month.month - 1]} ${month.year}';
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final months = [
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

    final weekday = weekdays[date.weekday % 7];
    final month = months[date.month - 1];

    return '$weekday, ${date.day} $month ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
