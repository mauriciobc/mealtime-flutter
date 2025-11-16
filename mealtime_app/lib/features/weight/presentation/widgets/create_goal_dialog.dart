import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/domain/entities/weight_goal.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_bloc.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_event.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_state.dart';
import 'package:uuid/uuid.dart';
import 'package:m3e_collection/m3e_collection.dart';

class CreateGoalDialog extends StatefulWidget {
  final Cat selectedCat;
  final List<WeightEntry> weightLogs;
  final WeightGoal? existingGoal; // Para edição futura

  const CreateGoalDialog({
    super.key,
    required this.selectedCat,
    required this.weightLogs,
    this.existingGoal,
  });

  @override
  State<CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<CreateGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetWeightController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 90));
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Calcular peso inicial baseado no primeiro registro ou peso atual do gato
    double startWeight = widget.selectedCat.currentWeight ?? 5.0;
    if (widget.weightLogs.isNotEmpty) {
      final sortedLogs = List<WeightEntry>.from(widget.weightLogs)
        ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
      startWeight = sortedLogs.first.weight;
    }

    // Se houver meta existente, preencher campos
    if (widget.existingGoal != null) {
      _targetWeightController.text =
          widget.existingGoal!.targetWeight.toStringAsFixed(1);
      _notesController.text = widget.existingGoal!.notes ?? '';
      _selectedDate = widget.existingGoal!.targetDate;
    } else {
      // Definir meta padrão baseada no peso inicial
      _targetWeightController.text = (startWeight * 0.9).toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double startWeight = widget.selectedCat.currentWeight ?? 5.0;
    if (widget.weightLogs.isNotEmpty) {
      final sortedLogs = List<WeightEntry>.from(widget.weightLogs)
        ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
      startWeight = sortedLogs.first.weight;
    }

    return BlocListener<WeightBloc, WeightState>(
      listener: (context, state) {
        if (state is WeightOperationSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is WeightError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText.rich(
                TextSpan(
                  text: 'Erro: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                  children: [
                    TextSpan(
                      text: state.failure.message,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: () {},
              ),
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: M3Motion.standard.duration,
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: M3Motion.standard.curve,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.92 + (0.08 * value), // Escala mais sutil M3
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'Nova Meta de Peso',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCatInfo(startWeight),
                  const SizedBox(height: 24),
                  _buildStartWeightDisplay(startWeight),
                  const SizedBox(height: 16),
                  _buildTargetWeightField(startWeight),
                  const SizedBox(height: 16),
                  _buildTargetDateField(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatInfo(double startWeight) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: widget.selectedCat.imageUrl != null
                ? NetworkImage(widget.selectedCat.imageUrl!)
                : null,
            onBackgroundImageError: (exception, stackTrace) {
              // Ignorar erro silenciosamente
            },
            child: widget.selectedCat.imageUrl == null
                ? Text(widget.selectedCat.name[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedCat.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Peso inicial: ${startWeight.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartWeightDisplay(double startWeight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(
              alpha: 0.3,
            ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Peso Inicial',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            '${startWeight.toStringAsFixed(1)} kg',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetWeightField(double startWeight) {
    return TextFormField(
      controller: _targetWeightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Peso Alvo (kg) *',
        hintText: 'Ex: 5.0',
        prefixIcon: const Icon(Icons.flag),
        suffixText: 'kg',
        border: const OutlineInputBorder(),
        helperText: 'Meta de peso a alcançar',
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Peso alvo é obrigatório';
        }
        final normalizedValue = value.replaceAll(',', '.').trim();
        final weight = double.tryParse(normalizedValue);
        if (weight == null) {
          return 'Digite um valor numérico válido';
        }
        if (weight <= 0) {
          return 'Peso deve ser maior que zero';
        }
        if (weight < 0.5) {
          return 'Peso deve ser pelo menos 0.5 kg';
        }
        if (weight > 20) {
          return 'Peso deve ser no máximo 20 kg';
        }
        if (weight == startWeight) {
          return 'Peso alvo deve ser diferente do peso inicial';
        }
        // Validação de diferença razoável (máximo 50% de variação)
        final maxVariation = startWeight * 0.5;
        if ((weight - startWeight).abs() > maxVariation) {
          return 'A variação do peso deve ser razoável (±${maxVariation.toStringAsFixed(1)} kg)';
        }
        // Validação adicional: verificar se há muitos dígitos decimais
        final parts = normalizedValue.split('.');
        if (parts.length > 1 && parts[1].length > 2) {
          return 'Use no máximo 2 casas decimais';
        }
        return null;
      },
    );
  }

  Widget _buildTargetDateField() {
    return InkWell(
      onTap: () => _selectDate(),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data Alvo *',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
          helperText: 'Data prevista para alcançar a meta',
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_selectedDate),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Observações',
        hintText: 'Notas sobre a meta...',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(
              alpha: 0.3,
            ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Este plano é um guia. Sempre siga orientação do veterinário.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicatorM3E(size: CircularProgressM3ESize.s),
                )
              : const Text('Criar Meta'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)), // Mínimo: amanhã
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a data alvo',
      errorFormatText: 'Data inválida',
      errorInvalidText: 'Data deve ser no futuro',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: 'Data da meta',
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      // Mostrar erro de validação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, corrija os erros no formulário'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Validação adicional de data alvo
    if (_selectedDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A data alvo deve ser no futuro (mínimo: amanhã)'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Validação de prazo razoável (máximo 1 ano)
    final maxDate = DateTime.now().add(const Duration(days: 365));
    if (_selectedDate.isAfter(maxDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A data alvo não pode ser mais de 1 ano no futuro'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    double startWeight = widget.selectedCat.currentWeight ?? 5.0;
    DateTime startDate = DateTime.now();

    if (widget.weightLogs.isNotEmpty) {
      final sortedLogs = List<WeightEntry>.from(widget.weightLogs)
        ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
      startWeight = sortedLogs.first.weight;
      startDate = sortedLogs.first.measuredAt;
    }

    final normalizedWeight = _targetWeightController.text.replaceAll(',', '.').trim();
    final targetWeight = double.parse(normalizedWeight);

    final goal = WeightGoal(
      id: widget.existingGoal?.id ?? const Uuid().v4(),
      catId: widget.selectedCat.id,
      targetWeight: targetWeight,
      startWeight: startWeight,
      startDate: startDate,
      targetDate: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.existingGoal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<WeightBloc>().add(CreateGoal(goal));
  }
}

