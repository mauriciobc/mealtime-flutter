import 'package:flutter/material.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';

class FeedingLogForm extends StatelessWidget {
  final TextEditingController catIdController;
  final TextEditingController homeIdController;
  final TextEditingController notesController;
  final TextEditingController amountController;
  final TextEditingController foodTypeController;
  final MealType selectedType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<MealType> onTypeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<String?> onCatSelected;
  final ValueChanged<String?> onHomeSelected;

  const FeedingLogForm({
    super.key,
    required this.catIdController,
    required this.homeIdController,
    required this.notesController,
    required this.amountController,
    required this.foodTypeController,
    required this.selectedType,
    required this.selectedDate,
    required this.selectedTime,
    required this.onTypeChanged,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onCatSelected,
    required this.onHomeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tipo de refeição
        Text(
          'Tipo de Refeição',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: MealType.values.map((type) {
            final isSelected = selectedType == type;
            return FilterChip(
              label: Text(_getTypeDisplayName(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onTypeChanged(type);
              },
              avatar: Icon(_getTypeIcon(type)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Gato
        TextFormField(
          controller: catIdController,
          decoration: const InputDecoration(
            labelText: 'ID do Gato *',
            hintText: 'Digite o ID do gato',
            prefixIcon: Icon(Icons.pets),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Selecione um gato';
            }
            return null;
          },
          onChanged: (value) =>
              onCatSelected(value.trim().isEmpty ? null : value.trim()),
        ),
        const SizedBox(height: 16),

        // Residência
        TextFormField(
          controller: homeIdController,
          decoration: const InputDecoration(
            labelText: 'ID da Residência *',
            hintText: 'Digite o ID da residência',
            prefixIcon: Icon(Icons.home),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Selecione uma residência';
            }
            return null;
          },
          onChanged: (value) =>
              onHomeSelected(value.trim().isEmpty ? null : value.trim()),
        ),
        const SizedBox(height: 24),

        // Data e hora
        Text(
          'Data e Hora',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: Text(_formatDate(selectedDate)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectTime(context),
                icon: const Icon(Icons.access_time),
                label: Text(_formatTime(selectedTime)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tipo de comida
        TextFormField(
          controller: foodTypeController,
          decoration: const InputDecoration(
            labelText: 'Tipo de Comida',
            hintText: 'Ex: Ração seca, Sache, Ração úmida...',
            prefixIcon: Icon(Icons.restaurant),
          ),
        ),
        const SizedBox(height: 16),

        // Quantidade
        TextFormField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Quantidade (gramas)',
            hintText: 'Ex: 150',
            prefixIcon: Icon(Icons.scale),
            suffixText: 'g',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Digite uma quantidade válida';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Observações
        TextFormField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Observações',
            hintText: 'Ex: Gato comeu bem, não gostou...',
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  String _getTypeDisplayName(MealType type) {
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

  IconData _getTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.wb_sunny_outlined;
      case MealType.dinner:
        return Icons.nightlight_round;
      case MealType.snack:
        return Icons.cookie;
    }
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

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      onDateChanged(date);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      onTimeChanged(time);
    }
  }
}
