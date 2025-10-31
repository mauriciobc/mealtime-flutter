import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_log_form.dart';
import 'package:uuid/uuid.dart';

class CreateFeedingLogPage extends StatefulWidget {
  final String? catId;
  final String? homeId;
  final String? householdId;

  const CreateFeedingLogPage({
    super.key,
    this.catId,
    this.homeId,
    this.householdId,
  });

  @override
  State<CreateFeedingLogPage> createState() => _CreateFeedingLogPageState();
}

class _CreateFeedingLogPageState extends State<CreateFeedingLogPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Form controllers
  late final TextEditingController _catIdController;
  late final TextEditingController _homeIdController;
  late final TextEditingController _notesController;
  late final TextEditingController _amountController;
  late final TextEditingController _foodTypeController;

  // Form values
  MealType _selectedType = MealType.breakfast;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedCatId;
  String? _selectedHomeId;

  @override
  void initState() {
    super.initState();
    _catIdController = TextEditingController(text: widget.catId ?? '');
    _homeIdController = TextEditingController(text: widget.homeId ?? '');
    _notesController = TextEditingController();
    _amountController = TextEditingController();
    _foodTypeController = TextEditingController();

    _selectedCatId = widget.catId;
    _selectedHomeId = widget.homeId;
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
        title: const Text('Nova Refeição'),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveFeedingLog,
                    icon: const Icon(Icons.save),
                    label: const Text('Criar Refeição'),
                  ),
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
        SnackBar(
          content: const Text('Selecione um gato e uma residência'),
          backgroundColor: Theme.of(context).colorScheme.error,
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

    final meal = FeedingLog(
      id: _uuid.v4(),
      catId: _selectedCatId!,
      householdId: _selectedHomeId!,
      mealType: _selectedType,
      fedAt: scheduledAt,
      fedBy: 'current-user-id', // TODO: Pegar do auth
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      amount: _amountController.text.trim().isEmpty
          ? null
          : double.tryParse(_amountController.text.trim()),
      unit: 'g',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<FeedingLogsBloc>().add(CreateFeedingLog(meal));
  }
}
