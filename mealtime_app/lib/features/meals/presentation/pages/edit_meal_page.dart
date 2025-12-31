import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_event.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_state.dart';
import 'package:mealtime_app/features/meals/presentation/widgets/meal_form.dart';

class EditMealPage extends StatefulWidget {
  final Meal meal;

  const EditMealPage({super.key, required this.meal});

  @override
  State<EditMealPage> createState() => _EditMealPageState();
}

class _EditMealPageState extends State<EditMealPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late final TextEditingController _catIdController;
  late final TextEditingController _homeIdController;
  late final TextEditingController _notesController;
  late final TextEditingController _amountController;
  late final TextEditingController _foodTypeController;

  // Form values
  late MealType _selectedType;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String? _selectedCatId;
  String? _selectedHomeId;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _catIdController = TextEditingController(text: widget.meal.catId);
    _homeIdController = TextEditingController(text: widget.meal.homeId);
    _notesController = TextEditingController(text: widget.meal.notes ?? '');
    _amountController = TextEditingController(
      text: widget.meal.amount?.toString() ?? '',
    );
    _foodTypeController = TextEditingController(
      text: widget.meal.foodType ?? '',
    );

    _selectedType = widget.meal.type;
    _selectedDate = widget.meal.scheduledAt;
    _selectedTime = TimeOfDay.fromDateTime(widget.meal.scheduledAt);
    _selectedCatId = widget.meal.catId;
    _selectedHomeId = widget.meal.homeId;
  }

  @override
  void dispose() {
    _catIdController.dispose();
    _homeIdController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    _foodTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Refeição'),
        actions: [
          TextButton(onPressed: _saveMeal, child: const Text('Salvar')),
        ],
      ),
      body: BlocListener<MealsBloc, MealsState>(
        listener: (context, state) {
          if (state is MealOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.of(context).pop();
          } else if (state is MealsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status da refeição
                Card(
                  color: _getStatusColor().withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(), color: _getStatusColor()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: ${widget.meal.statusDisplayName}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: _getStatusColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (widget.meal.completedAt != null)
                                Text(
                                  'Concluída em: ${_formatDateTime(widget.meal.completedAt!)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              if (widget.meal.skippedAt != null)
                                Text(
                                  'Pulada em: ${_formatDateTime(widget.meal.skippedAt!)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                MealForm(
                  catIdController: _catIdController,
                  homeIdController: _homeIdController,
                  notesController: _notesController,
                  amountController: _amountController,
                  foodTypeController: _foodTypeController,
                  selectedType: _selectedType,
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onTypeChanged: (type) => setState(() => _selectedType = type),
                  onDateChanged: (date) => setState(() => _selectedDate = date),
                  onTimeChanged: (time) => setState(() => _selectedTime = time),
                  onCatSelected: (catId) =>
                      setState(() => _selectedCatId = catId),
                  onHomeSelected: (homeId) =>
                      setState(() => _selectedHomeId = homeId),
                ),
                const SizedBox(height: 24),

                // Botões de ação
                BlocBuilder<MealsBloc, MealsState>(
                  builder: (context, state) {
                    final bool isLoading = state is MealOperationInProgress;

                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _deleteMeal,
                            icon: isLoading
                                ? const SizedBox.shrink()
                                : const Icon(Icons.delete),
                            label: isLoading
                                ? const SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text('Excluir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _saveMeal,
                            icon: isLoading
                                ? const SizedBox.shrink()
                                : const Icon(Icons.save),
                            label: isLoading
                                ? const SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text('Salvar'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveMeal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCatId == null || _selectedHomeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um gato e uma residência'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedMeal = widget.meal.copyWith(
      catId: _selectedCatId!,
      homeId: _selectedHomeId!,
      type: _selectedType,
      scheduledAt: scheduledAt,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      amount: _amountController.text.trim().isEmpty
          ? null
          : double.tryParse(_amountController.text.trim()),
      foodType: _foodTypeController.text.trim().isEmpty
          ? null
          : _foodTypeController.text.trim(),
      updatedAt: DateTime.now(),
    );

    context.read<MealsBloc>().add(UpdateMeal(updatedMeal));
  }

  void _deleteMeal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Refeição'),
        content: const Text(
          'Tem certeza que deseja excluir esta refeição? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MealsBloc>().add(DeleteMeal(widget.meal.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.meal.status) {
      case MealStatus.scheduled:
        return widget.meal.isOverdue ? Colors.red : Colors.blue;
      case MealStatus.completed:
        return Colors.green;
      case MealStatus.skipped:
        return Colors.orange;
      case MealStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.meal.status) {
      case MealStatus.scheduled:
        return widget.meal.isOverdue ? Icons.warning : Icons.schedule;
      case MealStatus.completed:
        return Icons.check_circle;
      case MealStatus.skipped:
        return Icons.skip_next;
      case MealStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
