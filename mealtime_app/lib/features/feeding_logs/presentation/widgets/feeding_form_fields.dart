import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealtime_app/features/feeding_logs/domain/food_type.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_bottom_sheet.dart';

class FeedingFormFields extends StatelessWidget {
  final FeedingFormData data;
  final ValueChanged<FeedingFormData> onChanged;

  const FeedingFormFields({
    super.key,
    required this.data,
    required this.onChanged,
  });

  static const List<String> statusOptions = [
    'Normal',
    'Reluctante',
    'Faminto',
    'Exigente',
  ];

  /// Valores são identificadores de domínio (dry_food, etc.); rótulos vêm da l10n.
  static List<String> get foodTypeIds => FoodTypeIds.all;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              _buildPortionField(context),
              const SizedBox(width: 4),
              Expanded(
                child: _buildStatusField(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildFoodTypeField(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildNotesField(context),
        ],
      ),
    );
  }

  /// Largura mínima para 3 dígitos + sufixo "g" (evita overflow no Row).
  static const double _portionFieldWidth = 60;

  Widget _buildPortionField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: _portionFieldWidth,
      child: TextFormField(
        initialValue: data.portion.toStringAsFixed(0),
        decoration: InputDecoration(
          labelText: 'Porção (g)',
          suffixText: 'g',
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          suffixStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          final portion = double.tryParse(value) ?? data.portion;
          if (portion > 0) {
            onChanged(data.copyWith(portion: portion));
          }
        },
      ),
    );
  }

  Widget _buildStatusField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: data.status,
      decoration: InputDecoration(
        labelText: 'Status',
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      dropdownColor: colorScheme.surfaceContainerHigh,
      selectedItemBuilder: (context) => statusOptions
          .map(
            (status) => Text(
              status,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
          .toList(),
      items: statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            status,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(data.copyWith(status: value));
        }
      },
    );
  }

  Widget _buildFoodTypeField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentValue =
        normalizeToFoodTypeId(data.foodType) ?? FoodTypeIds.dryFood;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: currentValue,
      decoration: InputDecoration(
        labelText: 'Tipo',
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      dropdownColor: colorScheme.surfaceContainerHigh,
      selectedItemBuilder: (context) => foodTypeIds
          .map(
            (id) => Text(
              localizedFoodType(context, id) ?? id,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
          .toList(),
      items: foodTypeIds.map((id) {
        return DropdownMenuItem<String>(
          value: id,
          child: Text(
            localizedFoodType(context, id) ?? id,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(data.copyWith(foodType: value));
        }
      },
    );
  }

  Widget _buildNotesField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return TextFormField(
      initialValue: data.notes,
      decoration: InputDecoration(
        labelText: 'Observações',
        hintText: 'Opcional',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        onChanged(data.copyWith(notes: value.isEmpty ? null : value));
      },
    );
  }
}

