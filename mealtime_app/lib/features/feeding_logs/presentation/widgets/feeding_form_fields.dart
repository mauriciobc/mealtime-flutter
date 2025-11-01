import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const List<String> foodTypeOptions = [
    'Ração Seca',
    'Ração Úmida',
    'Sachê',
    'Petisco',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPortionField(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusField(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFoodTypeField(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotesField(context),
        ],
      ),
    );
  }

  Widget _buildPortionField(BuildContext context) {
    return TextFormField(
      initialValue: data.portion.toStringAsFixed(0),
      decoration: InputDecoration(
        labelText: 'Porção (g)',
        suffixText: 'g',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
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
    );
  }

  Widget _buildStatusField(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('status_${data.status}'),
      initialValue: data.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      items: statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            status,
            style: const TextStyle(fontSize: 14),
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
    return DropdownButtonFormField<String>(
      key: ValueKey('foodType_${data.foodType}'),
      initialValue: data.foodType,
      decoration: const InputDecoration(
        labelText: 'Tipo',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      items: foodTypeOptions.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            type,
            style: const TextStyle(fontSize: 14),
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
    return TextFormField(
      initialValue: data.notes,
      decoration: const InputDecoration(
        labelText: 'Observações',
        hintText: 'Opcional',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
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

