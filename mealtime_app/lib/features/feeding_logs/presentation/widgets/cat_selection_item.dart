import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_bottom_sheet.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_form_fields.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class CatSelectionItem extends StatelessWidget {
  final Cat cat;
  final bool isSelected;
  final FeedingFormData? formData;
  final ValueChanged<bool> onSelectionChanged;
  final ValueChanged<FeedingFormData> onFormDataChanged;
  final List<FeedingLog>? feedingLogs;

  const CatSelectionItem({
    super.key,
    required this.cat,
    required this.isSelected,
    required this.formData,
    required this.onSelectionChanged,
    required this.onFormDataChanged,
    this.feedingLogs,
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
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
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
                  _buildCatAvatar(context),
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

  Widget _buildCatAvatar(BuildContext context) {
    final theme = Theme.of(context);
    
    // Validar se a URL existe e é válida (começa com http)
    final imageUrl = cat.imageUrl;
    final hasValidImageUrl = imageUrl != null && 
        imageUrl.isNotEmpty && 
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    
    if (hasValidImageUrl) {
      return SizedBox(
        width: 40,
        height: 40,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl.trim(),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 40,
              height: 40,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Material3LoadingIndicator(size: 20.0),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                width: 40,
                height: 40,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.pets,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
      );
    }
    
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.pets,
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _getLastFeedingText() {
    if (feedingLogs == null || feedingLogs!.isEmpty) {
      return 'Nunca alimentado';
    }

    // Filtra os feeding logs deste gato
    final catFeedings = feedingLogs!.where((log) => log.catId == cat.id).toList();
    
    if (catFeedings.isEmpty) {
      return 'Nunca alimentado';
    }

    // Ordena por data (mais recente primeiro)
    catFeedings.sort((a, b) => b.fedAt.compareTo(a.fedAt));
    
    final lastFeeding = catFeedings.first;
    final now = DateTime.now();
    final difference = now.difference(lastFeeding.fedAt);

    if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inDays < 30) {
      return 'há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'há $months ${months == 1 ? 'mês' : 'meses'}';
    }
  }
}

