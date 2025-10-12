import 'package:flutter/material.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_bottom_sheet.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_form_fields.dart';

class CatSelectionItem extends StatelessWidget {
  final Cat cat;
  final bool isSelected;
  final FeedingFormData? formData;
  final ValueChanged<bool> onSelectionChanged;
  final ValueChanged<FeedingFormData> onFormDataChanged;

  const CatSelectionItem({
    super.key,
    required this.cat,
    required this.isSelected,
    required this.formData,
    required this.onSelectionChanged,
    required this.onFormDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => onSelectionChanged(!isSelected),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) => onSelectionChanged(value ?? false),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.pets,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Última refeição: ${_getLastFeedingText()}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isSelected && formData != null
                ? FeedingFormFields(
                    data: formData!,
                    onChanged: onFormDataChanged,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _getLastFeedingText() {
    // TODO: Implementar lógica real de última refeição
    // Por enquanto, retorna texto placeholder
    return 'há 12 dias';
  }
}

