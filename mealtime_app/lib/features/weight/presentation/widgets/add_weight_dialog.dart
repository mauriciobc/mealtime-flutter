import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/entities/weight_entry.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_bloc.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_event.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_state.dart';
import 'package:uuid/uuid.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

class AddWeightDialog extends StatefulWidget {
  final Cat? selectedCat;
  final WeightEntry? weightEntry; // Para edição

  const AddWeightDialog({
    super.key,
    this.selectedCat,
    this.weightEntry,
  });

  @override
  State<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<AddWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.weightEntry != null) {
      _weightController.text = widget.weightEntry!.weight.toStringAsFixed(2);
      _notesController.text = widget.weightEntry!.notes ?? '';
      _selectedDate = widget.weightEntry!.measuredAt;
      _selectedTime = TimeOfDay.fromDateTime(widget.weightEntry!.measuredAt);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    duration: M3Animation.durationShort4, // 300ms M3
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: M3Animation.deceleratedCurve, // Entrada M3
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
                      widget.weightEntry != null
                          ? 'Editar Registro de Peso'
                          : 'Registrar Peso',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.selectedCat != null) ...[
                    _buildCatInfo(),
                    const SizedBox(height: 16),
                  ],
                  _buildWeightField(),
                  const SizedBox(height: 16),
                  _buildDateTimeFields(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
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

  Widget _buildCatInfo() {
    final cat = widget.selectedCat!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: cat.imageUrl != null
                ? NetworkImage(cat.imageUrl!)
                : null,
            onBackgroundImageError: (exception, stackTrace) {
              // Ignorar erro silenciosamente
            },
            child: cat.imageUrl == null
                ? Text(cat.name[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (cat.currentWeight != null)
                  Text(
                    'Peso atual: ${cat.currentWeight!.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Peso (kg) *',
        hintText: 'Ex: 5.5',
        prefixIcon: const Icon(Icons.monitor_weight),
        suffixText: 'kg',
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Peso é obrigatório';
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
        // Validação adicional: verificar se há muitos dígitos decimais
        final parts = normalizedValue.split('.');
        if (parts.length > 1 && parts[1].length > 2) {
          return 'Use no máximo 2 casas decimais';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimeFields() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data *',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectTime(),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Hora *',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
              child: Text(
                _selectedTime.format(context),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Observações',
        hintText: 'Notas adicionais sobre o peso...',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
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
              : Text(widget.weightEntry != null ? 'Atualizar' : 'Registrar'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data',
      errorFormatText: 'Data inválida',
      errorInvalidText: 'Data fora do intervalo permitido',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: 'Data da medição',
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Selecione a hora',
      errorInvalidText: 'Hora inválida',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
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
    
    if (widget.selectedCat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione um gato primeiro'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Validação adicional de data/hora
    final measuredAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (measuredAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A data e hora não podem ser no futuro'),
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

    final normalizedWeight = _weightController.text.replaceAll(',', '.').trim();
    final weight = double.parse(normalizedWeight);

    final weightEntry = WeightEntry(
      id: widget.weightEntry?.id ?? const Uuid().v4(),
      catId: widget.selectedCat!.id,
      weight: weight,
      measuredAt: measuredAt,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.weightEntry?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.weightEntry != null) {
      context.read<WeightBloc>().add(UpdateWeightLog(weightEntry));
    } else {
      context.read<WeightBloc>().add(CreateWeightLog(weightEntry));
    }
  }
}

