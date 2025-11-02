import 'package:flutter/material.dart';
import 'package:mealtime_app/features/statistics/domain/entities/statistics_data.dart';

/// Cards de resumo das estatísticas
class StatisticsSummaryCards extends StatelessWidget {
  final StatisticsData statistics;

  const StatisticsSummaryCards({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total',
            value: statistics.totalFeedings.toString(),
            subtitle: 'Alimentações',
            icon: Icons.restaurant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Média',
            value: _formatAmount(statistics.averagePortion),
            subtitle: 'Por refeição',
            icon: Icons.balance,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Ativos',
            value: statistics.activeCats.toString(),
            subtitle: 'Gatos',
            icon: Icons.pets,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == 0) return '0 g';
    return '${amount.toStringAsFixed(1)} g';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

