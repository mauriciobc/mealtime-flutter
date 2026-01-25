import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_event.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_state.dart';
import 'package:mealtime_app/features/meals/presentation/widgets/meal_form.dart';
import 'package:uuid/uuid.dart';

class CreateMealPage extends StatefulWidget {
  final String? catId;
  final String? homeId;

  const CreateMealPage({super.key, this.catId, this.homeId});

  @override
  State<CreateMealPage> createState() => _CreateMealPageState();
}

class _CreateMealPageState extends State<CreateMealPage> {
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
    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        final isLoading = state is MealOperationInProgress;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nova Refeição'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: isLoading ? null : _saveMeal,
                tooltip: 'Salvar',
              ),
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
                    MealForm(
                      catIdController: _catIdController,
                      homeIdController: _homeIdController,
                      notesController: _notesController,
                      amountController: _amountController,
                      foodTypeController: _foodTypeController,
                      selectedType: _selectedType,
                      selectedDate: _selectedDate,
                      selectedTime: _selectedTime,
                      onTypeChanged: (type) =>
                          setState(() => _selectedType = type),
                      onDateChanged: (date) =>
                          setState(() => _selectedDate = date),
                      onTimeChanged: (time) =>
                          setState(() => _selectedTime = time),
                      onCatSelected: (catId) =>
                          setState(() => _selectedCatId = catId),
                      onHomeSelected: (homeId) =>
                          setState(() => _selectedHomeId = homeId),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _saveMeal,
                        icon: isLoading
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(Icons.save),
                        label:
                            Text(isLoading ? 'Salvando...' : 'Criar Refeição'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

    final meal = Meal(
      id: _uuid.v4(),
      catId: _selectedCatId!,
      homeId: _selectedHomeId!,
      type: _selectedType,
      scheduledAt: scheduledAt,
      status: MealStatus.scheduled,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      amount: _amountController.text.trim().isEmpty
          ? null
          : double.tryParse(_amountController.text.trim()),
      foodType: _foodTypeController.text.trim().isEmpty
          ? null
          : _foodTypeController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<MealsBloc>().add(CreateMeal(meal));
  }
}
