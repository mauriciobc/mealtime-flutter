import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/meal.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/meal_form.dart';

class EditFeedingLogPage extends StatefulWidget {
  final FeedingLog meal;

  const EditFeedingLogPage({super.key, required this.meal});

  @override
  State<EditFeedingLogPage> createState() => _EditFeedingLogPageState();
}

class _EditFeedingLogPageState extends State<EditFeedingLogPage> {
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
          TextButton(onPressed: _saveFeedingLog, child: const Text('Salvar')),
        ],
      ),
      body: BlocListener<FeedingLogsBloc, FeedingLogsState>(
        listener: (context, state) {
          if (state is FeedingLogOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.of(context).pop();
          } else if (state is FeedingLogsError) {
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

                FeedingLogForm(
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _deleteFeedingLog,
                        icon: const Icon(Icons.delete),
                        label: const Text('Excluir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveFeedingLog,
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveFeedingLog() {
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

    final updatedFeedingLog = widget.meal.copyWith(
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

    context.read<FeedingLogsBloc>().add(UpdateFeedingLog(updatedFeedingLog));
  }

  void _deleteFeedingLog() {
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
              context.read<FeedingLogsBloc>().add(DeleteFeedingLog(widget.meal.id));
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
      case FeedingLogStatus.scheduled:
        return widget.meal.isOverdue ? Colors.red : Colors.blue;
      case FeedingLogStatus.completed:
        return Colors.green;
      case FeedingLogStatus.skipped:
        return Colors.orange;
      case FeedingLogStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.meal.status) {
      case FeedingLogStatus.scheduled:
        return widget.meal.isOverdue ? Icons.warning : Icons.schedule;
      case FeedingLogStatus.completed:
        return Icons.check_circle;
      case FeedingLogStatus.skipped:
        return Icons.skip_next;
      case FeedingLogStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
