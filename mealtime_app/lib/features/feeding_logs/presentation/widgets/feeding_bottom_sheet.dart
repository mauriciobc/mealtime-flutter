import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/cat_selection_item.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:uuid/uuid.dart';

class FeedingFormData {
  final String catId;
  final double portion;
  final String status;
  final String foodType;
  final String? notes;

  FeedingFormData({
    required this.catId,
    this.portion = 10.0,
    this.status = 'Normal',
    this.foodType = 'Ração Seca',
    this.notes,
  });

  FeedingFormData copyWith({
    double? portion,
    String? status,
    String? foodType,
    String? notes,
  }) {
    return FeedingFormData(
      catId: catId,
      portion: portion ?? this.portion,
      status: status ?? this.status,
      foodType: foodType ?? this.foodType,
      notes: notes ?? this.notes,
    );
  }
}

class FeedingBottomSheet extends StatefulWidget {
  final List<Cat> availableCats;
  final String householdId;

  const FeedingBottomSheet({
    super.key,
    required this.availableCats,
    required this.householdId,
  });

  @override
  State<FeedingBottomSheet> createState() => _FeedingBottomSheetState();
}

class _FeedingBottomSheetState extends State<FeedingBottomSheet> {
  final Set<String> _selectedCatIds = {};
  final Map<String, FeedingFormData> _feedingData = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildSelectionControls(),
            const Divider(height: 1),
            Expanded(
              child: _buildCatsList(),
            ),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Registrar Nova Alimentação',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecione os gatos e informe os detalhes da refeição.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSelectionControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_selectedCatIds.length} de ${widget.availableCats.length} gatos selecionados',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: _selectAll,
                child: const Text('Todos'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _selectedCatIds.isEmpty ? null : _clearAll,
                child: const Text('Limpar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatsList() {
    return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
      builder: (context, state) {
        List<FeedingLog> feedingLogs = [];
        if (state is FeedingLogsLoaded) {
          feedingLogs = state.feeding_logs;
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: widget.availableCats.length,
          itemBuilder: (context, index) {
            final cat = widget.availableCats[index];
            final isSelected = _selectedCatIds.contains(cat.id);
            final formData = _feedingData[cat.id];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CatSelectionItem(
                cat: cat,
                isSelected: isSelected,
                formData: formData,
                onSelectionChanged: (selected) => _toggleCatSelection(cat.id, selected),
                onFormDataChanged: (data) => _updateFormData(cat.id, data),
                feedingLogs: feedingLogs,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedCatIds.isEmpty || _isSubmitting
              ? null
              : _submitFeedings,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSubmitting
              ? const Material3LoadingIndicator(size: 20.0)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check),
                    const SizedBox(width: 8),
                    Text(
                      'Confirmar Alimentação (${_selectedCatIds.length})',
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _toggleCatSelection(String catId, bool selected) {
    setState(() {
      if (selected) {
        _selectedCatIds.add(catId);
        _feedingData[catId] = FeedingFormData(catId: catId);
      } else {
        _selectedCatIds.remove(catId);
        _feedingData.remove(catId);
      }
    });
  }

  void _updateFormData(String catId, FeedingFormData data) {
    setState(() {
      _feedingData[catId] = data;
    });
  }

  void _selectAll() {
    setState(() {
      for (final cat in widget.availableCats) {
        if (!_selectedCatIds.contains(cat.id)) {
          _selectedCatIds.add(cat.id);
          _feedingData[cat.id] = FeedingFormData(catId: cat.id);
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedCatIds.clear();
      _feedingData.clear();
    });
  }

  Future<void> _submitFeedings() async {
    if (_selectedCatIds.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      // Obter userId do AuthBloc
      final authState = context.read<AuthBloc>().state;
      String? userId;
      
      if (authState is AuthSuccess) {
        userId = authState.user.id;
      } else {
        // Se não estiver autenticado, mostrar erro
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Usuário não autenticado. Faça login novamente.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      if (userId.isEmpty) {
        throw Exception('ID do usuário não encontrado');
      }

      final now = DateTime.now();
      final feedingLogsBloc = context.read<FeedingLogsBloc>();
      
      // Preparar lista de feedings para criar em batch
      final feedingLogs = <FeedingLog>[];
      
      for (final catId in _selectedCatIds) {
        final data = _feedingData[catId]!;

        final feedingLog = FeedingLog(
          id: const Uuid().v4(),
          catId: catId,
          householdId: widget.householdId,
          mealType: MealType.snack,
          fedAt: now,
          fedBy: userId,
          amount: data.portion,
          unit: 'g',
          notes: data.notes?.isEmpty ?? true ? null : data.notes,
          createdAt: now,
          updatedAt: now,
        );
        
        feedingLogs.add(feedingLog);
      }

      // Criar todos os feedings em batch
      if (mounted) {
        feedingLogsBloc.add(CreateFeedingLogsBatch(feedingLogs));
      }

      // Aguardar processamento
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Verificar se houve erros
        final currentState = feedingLogsBloc.state;
        int successCount = feedingLogs.length;
        String? lastError;

        if (currentState is FeedingLogsError) {
          lastError = currentState.failure.message;
          successCount = 0;
        } else if (currentState is FeedingLogOperationSuccess) {
          successCount = currentState.feeding_logs.length;
        }

        Navigator.of(context).pop();

        // Recarregar feedings após criação usando householdId
        feedingLogsBloc.add(LoadTodayFeedingLogs(householdId: widget.householdId));

        // Mostrar mensagem de sucesso ou erro
        if (lastError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao registrar alimentação: $lastError'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Alimentação registrada para $successCount gato(s)!',
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar alimentação: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

