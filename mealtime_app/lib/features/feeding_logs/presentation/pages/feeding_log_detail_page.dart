import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/meal.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';

class FeedingLogDetailPage extends StatelessWidget {
  final String mealId;

  const FeedingLogDetailPage({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Refeição'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
        builder: (context, state) {
          if (state is FeedingLogsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FeedingLogsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.failure.message,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FeedingLogsBloc>().add(LoadFeedingLogById(mealId));
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is FeedingLogLoaded) {
            return _buildFeedingLogDetails(context, state.meal);
          }

          // Carregar refeição se ainda não foi carregada
          if (state is! FeedingLogOperationInProgress) {
            context.read<FeedingLogsBloc>().add(LoadFeedingLogById(mealId));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFeedingLogDetails(BuildContext context, FeedingLog meal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card principal com informações básicas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildMealTypeIcon(meal.type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.typeDisplayName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(meal.scheduledAt),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(context, meal),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (meal.notes != null) ...[
                    _buildInfoRow(
                      context,
                      Icons.note,
                      'Observações',
                      meal.notes!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (meal.amount != null) ...[
                    _buildInfoRow(
                      context,
                      Icons.scale,
                      'Quantidade',
                      '${meal.amount!.toStringAsFixed(0)}g',
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (meal.foodType != null) ...[
                    _buildInfoRow(
                      context,
                      Icons.restaurant,
                      'Tipo de Comida',
                      meal.foodType!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildInfoRow(context, Icons.pets, 'ID do Gato', meal.catId),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.home,
                    'ID da Residência',
                    meal.homeId,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card com informações de status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status da Refeição',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusInfo(context, meal),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card com informações de tempo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações de Tempo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.schedule,
                    'Agendada para',
                    _formatDateTime(meal.scheduledAt),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.add_circle_outline,
                    'Criada em',
                    _formatDateTime(meal.createdAt),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.update,
                    'Atualizada em',
                    _formatDateTime(meal.updatedAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botões de ação
          if (meal.status == FeedingLogStatus.scheduled) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _skipFeedingLog(context, meal),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Pular'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _completeFeedingLog(context, meal),
                    icon: const Icon(Icons.check),
                    label: const Text('Concluir'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealTypeIcon(MealType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case MealType.breakfast:
        iconData = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case MealType.lunch:
        iconData = Icons.wb_sunny_outlined;
        color = Colors.amber;
        break;
      case MealType.dinner:
        iconData = Icons.nightlight_round;
        color = Colors.indigo;
        break;
      case MealType.snack:
        iconData = Icons.cookie;
        color = Colors.brown;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color, size: 32),
    );
  }

  Widget _buildStatusChip(BuildContext context, FeedingLog meal) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (meal.status) {
      case FeedingLogStatus.scheduled:
        if (meal.isOverdue) {
          backgroundColor = Colors.red.withOpacity(0.1);
          textColor = Colors.red;
          text = 'Atrasada';
        } else {
          backgroundColor = Colors.blue.withOpacity(0.1);
          textColor = Colors.blue;
          text = 'Agendada';
        }
        break;
      case FeedingLogStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        text = 'Concluída';
        break;
      case FeedingLogStatus.skipped:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Pulada';
        break;
      case FeedingLogStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        text = 'Cancelada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo(BuildContext context, FeedingLog meal) {
    switch (meal.status) {
      case FeedingLogStatus.scheduled:
        return Column(
          children: [
            _buildInfoRow(
              context,
              Icons.schedule,
              'Status',
              meal.isOverdue ? 'Atrasada' : 'Agendada',
            ),
            if (meal.isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta refeição está atrasada',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      case FeedingLogStatus.completed:
        return Column(
          children: [
            _buildInfoRow(context, Icons.check_circle, 'Status', 'Concluída'),
            if (meal.completedAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.access_time,
                'Concluída em',
                _formatDateTime(meal.completedAt!),
              ),
            ],
          ],
        );
      case FeedingLogStatus.skipped:
        return Column(
          children: [
            _buildInfoRow(context, Icons.skip_next, 'Status', 'Pulada'),
            if (meal.skippedAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.access_time,
                'Pulada em',
                _formatDateTime(meal.skippedAt!),
              ),
            ],
          ],
        );
      case FeedingLogStatus.cancelled:
        return _buildInfoRow(context, Icons.cancel, 'Status', 'Cancelada');
    }
  }

  String _formatDateTime(DateTime dateTime) {
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

    final weekday = weekdays[dateTime.weekday % 7];
    final month = months[dateTime.month - 1];
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$weekday, ${dateTime.day} $month ${dateTime.year} às $time';
  }

  void _navigateToEdit(BuildContext context) {
    // TODO: Implementar navegação para edição
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Editar refeição')));
  }

  void _completeFeedingLog(BuildContext context, FeedingLog meal) {
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

  void _skipFeedingLog(BuildContext context, FeedingLog meal) {
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
