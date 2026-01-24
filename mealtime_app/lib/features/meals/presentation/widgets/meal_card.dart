import 'package:flutter/material.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/presentation/view_models/meal_view_model.dart';

class MealCard extends StatelessWidget {
  final MealViewModel meal;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onComplete,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMealTypeIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.meal.typeDisplayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal.formattedDateTime,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              if (meal.meal.notes != null) ...[
                const SizedBox(height: 12),
                Text(
                  meal.meal.notes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (meal.meal.amount != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.scale,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meal.meal.amount!.toStringAsFixed(0)}g',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
              if (meal.meal.foodType != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meal.meal.foodType!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
              if (meal.meal.status == MealStatus.scheduled) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSkip,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Pular'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onComplete,
                        icon: const Icon(Icons.check),
                        label: const Text('Concluir'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeIcon() {
    IconData iconData;
    Color color;

    switch (meal.meal.type) {
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (meal.meal.status) {
      case MealStatus.scheduled:
        if (meal.meal.isOverdue) {
          backgroundColor = Colors.red.withOpacity(0.1);
          textColor = Colors.red;
          text = 'Atrasada';
        } else {
          backgroundColor = Colors.blue.withOpacity(0.1);
          textColor = Colors.blue;
          text = 'Agendada';
        }
        break;
      case MealStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        text = 'Concluída';
        break;
      case MealStatus.skipped:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Pulada';
        break;
      case MealStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        text = 'Cancelada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
