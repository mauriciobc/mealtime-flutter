import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/meal.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/meal_card.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class FeedingLogsListPage extends StatefulWidget {
  final String? catId;
  final bool showTodayOnly;

  const FeedingLogsListPage({super.key, this.catId, this.showTodayOnly = false});

  @override
  State<FeedingLogsListPage> createState() => _FeedingLogsListPageState();
}

class _FeedingLogsListPageState extends State<FeedingLogsListPage> {
  @override
  void initState() {
    super.initState();
    _loadFeedingLogs();
  }

  void _loadFeedingLogs() {
    if (widget.showTodayOnly) {
      context.read<FeedingLogsBloc>().add(const LoadTodayFeedingLogs());
    } else if (widget.catId != null) {
      context.read<FeedingLogsBloc>().add(LoadFeedingLogsByCat(widget.catId!));
    } else {
      context.read<FeedingLogsBloc>().add(const LoadFeedingLogs());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showTodayOnly
              ? 'Refeições de Hoje'
              : widget.catId != null
              ? 'Refeições do Gato'
              : 'Todas as Refeições',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFeedingLogs),
        ],
      ),
      body: BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
        builder: (context, state) {
          if (state is FeedingLogsLoading) {
            return const LoadingWidget();
          }

          if (state is FeedingLogsError) {
            return CustomErrorWidget(
              message: state.failure.message,
              onRetry: _loadFeedingLogs,
            );
          }

          if (state is FeedingLogsLoaded) {
            if (state.feeding_logs.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadFeedingLogs();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.feeding_logs.length,
                itemBuilder: (context, index) {
                  final meal = state.feeding_logs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FeedingLogCard(
                      meal: meal,
                      onTap: () => _navigateToFeedingLogDetail(meal),
                      onComplete: () => _completeFeedingLog(meal),
                      onSkip: () => _skipFeedingLog(meal),
                    ),
                  );
                },
              ),
            );
          }

          if (state is FeedingLogOperationInProgress) {
            return Stack(
              children: [
                if (state.feeding_logs.isNotEmpty)
                  RefreshIndicator(
                    onRefresh: () async {
                      _loadFeedingLogs();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.feeding_logs.length,
                      itemBuilder: (context, index) {
                        final meal = state.feeding_logs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FeedingLogCard(
                            meal: meal,
                            onTap: () => _navigateToFeedingLogDetail(meal),
                            onComplete: () => _completeFeedingLog(meal),
                            onSkip: () => _skipFeedingLog(meal),
                          ),
                        );
                      },
                    ),
                  )
                else
                  _buildEmptyState(),
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(state.operation),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateFeedingLog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            widget.showTodayOnly
                ? 'Nenhuma refeição agendada para hoje'
                : 'Nenhuma refeição encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.showTodayOnly
                ? 'Adicione refeições para seus gatos'
                : 'Comece criando uma nova refeição',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateFeedingLog,
            icon: const Icon(Icons.add),
            label: const Text('Criar Refeição'),
          ),
        ],
      ),
    );
  }

  void _navigateToFeedingLogDetail(FeedingLog meal) {
    // TODO: Implementar navegação para detalhes da refeição
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Detalhes da refeição: ${meal.id}')));
  }

  void _navigateToCreateFeedingLog() {
    // TODO: Implementar navegação para criar refeição
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Criar nova refeição')));
  }

  void _completeFeedingLog(FeedingLog meal) {
    showDialog(
      context: context,
      builder: (context) => _CompleteFeedingLogDialog(
        meal: meal,
        onComplete: (notes, amount) {
          context.read<FeedingLogsBloc>().add(
            CompleteFeedingLog(mealId: meal.id, notes: notes, amount: amount),
          );
        },
      ),
    );
  }

  void _skipFeedingLog(FeedingLog meal) {
    showDialog(
      context: context,
      builder: (context) => _SkipFeedingLogDialog(
        meal: meal,
        onSkip: (reason) {
          context.read<FeedingLogsBloc>().add(
            SkipFeedingLog(mealId: meal.id, reason: reason),
          );
        },
      ),
    );
  }
}

class _CompleteFeedingLogDialog extends StatefulWidget {
  final FeedingLog meal;
  final Function(String? notes, double? amount) onComplete;

  const _CompleteFeedingLogDialog({required this.meal, required this.onComplete});

  @override
  State<_CompleteFeedingLogDialog> createState() => _CompleteFeedingLogDialogState();
}

class _CompleteFeedingLogDialogState extends State<_CompleteFeedingLogDialog> {
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Concluir ${widget.meal.typeDisplayName}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                hintText: 'Ex: Comeu bem, não gostou...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Quantidade (gramas)',
                hintText: 'Ex: 150',
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final notes = _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim();
              final amount = _amountController.text.trim().isEmpty
                  ? null
                  : double.tryParse(_amountController.text.trim());

              widget.onComplete(notes, amount);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Concluir'),
        ),
      ],
    );
  }
}

class _SkipFeedingLogDialog extends StatefulWidget {
  final FeedingLog meal;
  final Function(String? reason) onSkip;

  const _SkipFeedingLogDialog({required this.meal, required this.onSkip});

  @override
  State<_SkipFeedingLogDialog> createState() => _SkipFeedingLogDialogState();
}

class _SkipFeedingLogDialogState extends State<_SkipFeedingLogDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pular ${widget.meal.typeDisplayName}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tem certeza que deseja pular esta refeição?'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ex: Gato não estava com fome...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _reasonController.text.trim().isEmpty
                ? null
                : _reasonController.text.trim();

            widget.onSkip(reason);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Pular'),
        ),
      ],
    );
  }
}
