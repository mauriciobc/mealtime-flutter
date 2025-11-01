/// Filtro de período para estatísticas
enum PeriodFilter {
  today,
  week,
  month,
  threeMonths,
  sixMonths,
  year,
  custom;

  /// Nome de exibição do período
  String get displayName {
    switch (this) {
      case today:
        return 'Hoje';
      case week:
        return 'Semana';
      case month:
        return 'Mês';
      case threeMonths:
        return '3 Meses';
      case sixMonths:
        return '6 Meses';
      case year:
        return 'Ano';
      case custom:
        return 'Personalizado';
    }
  }

  /// Calcula o range de datas baseado no período
  /// Retorna (startDate, endDate)
  (DateTime start, DateTime end) getDateRange({
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startOfDay = DateTime(now.year, now.month, now.day);

    switch (this) {
      case today:
        return (startOfDay, endOfDay);

      case week:
        final start = startOfDay.subtract(
          Duration(days: now.weekday - 1),
        );
        return (start, endOfDay);

      case month:
        final start = DateTime(now.year, now.month, 1);
        return (start, endOfDay);

      case threeMonths:
        final start = DateTime(now.year, now.month - 2, 1);
        return (start, endOfDay);

      case sixMonths:
        final start = DateTime(now.year, now.month - 5, 1);
        return (start, endOfDay);

      case year:
        final start = DateTime(now.year, 1, 1);
        return (start, endOfDay);

      case custom:
        if (customStart != null && customEnd != null) {
          final start = DateTime(
            customStart.year,
            customStart.month,
            customStart.day,
          );
          final end = DateTime(
            customEnd.year,
            customEnd.month,
            customEnd.day,
            23,
            59,
            59,
          );
          return (start, end);
        }
        // Fallback para semana se não especificado
        final start = startOfDay.subtract(
          Duration(days: now.weekday - 1),
        );
        return (start, endOfDay);
    }
  }
}

