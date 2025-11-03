import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

class CatDetailPage extends StatefulWidget {
  final String catId;

  const CatDetailPage({super.key, required this.catId});

  @override
  State<CatDetailPage> createState() => _CatDetailPageState();
}

class _CatDetailPageState extends State<CatDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CatsBloc>().add(LoadCatById(widget.catId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Gato'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.push('/edit-cat/${widget.catId}');
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Excluir',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<CatsBloc, CatsState>(
        listener: (context, state) {
          if (state is CatOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            if (state.message.contains('excluído')) {
              context.pop();
            }
          } else if (state is CatsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CatsLoading) {
            return const LoadingWidget();
          } else if (state is CatsError) {
            return CustomErrorWidget(
              message: state.failure.message,
              onRetry: () {
                context.read<CatsBloc>().add(LoadCatById(widget.catId));
              },
            );
          } else if (state is CatLoaded) {
            return _buildCatDetails(context, state.cat);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCatDetails(BuildContext context, dynamic cat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCatHeader(context, cat),
          const SizedBox(height: 24),
          _buildCatInfo(context, cat),
          const SizedBox(height: 24),
          _buildWeightSection(context, cat),
          const SizedBox(height: 24),
          _buildDescriptionSection(context, cat),
        ],
      ),
    );
  }

  Widget _buildCatHeader(BuildContext context, dynamic cat) {
    final theme = Theme.of(context);
    
    // Validar se a URL existe e é válida (começa com http)
    final imageUrl = cat.imageUrl;
    final hasValidImageUrl = imageUrl != null && 
        imageUrl.isNotEmpty && 
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    
    Widget avatarWidget;
    if (hasValidImageUrl) {
      avatarWidget = SizedBox(
        width: 80,
        height: 80,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl.trim(),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 80,
              height: 80,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Material3LoadingIndicator(size: 32.0),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                width: 80,
                height: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.pets,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),
        ),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 40,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.pets,
          size: 40,
          color: theme.colorScheme.primary,
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            avatarWidget,
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (cat.breed != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      cat.breed!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cat.ageDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (cat.gender != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          cat.gender == 'M' ? Icons.male : Icons.female,
                          size: 16,
                          color: cat.gender == 'M'
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat.gender == 'M' ? 'Macho' : 'Fêmea',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatInfo(BuildContext context, dynamic cat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Nome', cat.name),
            if (cat.breed != null) _buildInfoRow(context, 'Raça', cat.breed!),
            if (cat.color != null) _buildInfoRow(context, 'Cor', cat.color!),
            _buildInfoRow(
              context,
              'Data de Nascimento',
              '${cat.birthDate.day}/${cat.birthDate.month}/${cat.birthDate.year}',
            ),
            _buildInfoRow(context, 'Idade', cat.ageDescription),
            if (cat.gender != null)
              _buildInfoRow(
                context,
                'Sexo',
                cat.gender == 'M' ? 'Macho' : 'Fêmea',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSection(BuildContext context, dynamic cat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peso',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (cat.currentWeight != null) ...[
              _buildInfoRow(
                context,
                'Peso Atual',
                '${cat.currentWeight!.toStringAsFixed(1)} kg',
              ),
              if (cat.targetWeight != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Peso Ideal',
                  '${cat.targetWeight!.toStringAsFixed(1)} kg',
                ),
                const SizedBox(height: 8),
                _buildWeightProgress(context, cat),
              ],
            ] else ...[
              Text(
                'Peso não informado',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showUpdateWeightDialog(context, cat);
                },
                icon: const Icon(Icons.monitor_weight),
                label: const Text('Atualizar Peso'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightProgress(BuildContext context, dynamic cat) {
    if (cat.currentWeight == null || cat.targetWeight == null) {
      return const SizedBox.shrink();
    }

    // Validar que targetWeight não seja zero para evitar divisão por zero
    if (cat.targetWeight == 0 || !cat.targetWeight!.isFinite) {
      return const SizedBox.shrink();
    }

    final progress = cat.currentWeight! / cat.targetWeight!;
    
    // Validar que o progress não seja NaN ou Infinity
    if (!progress.isFinite) {
      return const SizedBox.shrink();
    }
    
    final isOverweight = progress > 1.1;
    final isUnderweight = progress < 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicatorM3E(
          value: progress.clamp(0.0, 1.5),
          trackColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          activeColor: isOverweight
              ? Theme.of(context).colorScheme.tertiary
              : isUnderweight
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 8),
        Text(
          _getWeightStatus(cat.currentWeight!, cat.targetWeight!),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isOverweight
                ? Theme.of(context).colorScheme.tertiary
                : isUnderweight
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getWeightStatus(double current, double target) {
    final diff = current - target;
    final percentage = ((diff / target) * 100).abs();

    if (diff > 0) {
      return 'Acima do peso ideal (+${percentage.toStringAsFixed(1)}%)';
    } else if (diff < 0) {
      return 'Abaixo do peso ideal (-${percentage.toStringAsFixed(1)}%)';
    } else {
      return 'Peso ideal';
    }
  }

  Widget _buildDescriptionSection(BuildContext context, dynamic cat) {
    if (cat.description == null || cat.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              cat.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showUpdateWeightDialog(BuildContext context, dynamic cat) {
    final weightController = TextEditingController(
      text: cat.currentWeight?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Peso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Atualizar peso de ${cat.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                context.read<CatsBloc>().add(UpdateCatWeight(cat.id, weight));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Gato'),
        content: const Text('Tem certeza que deseja excluir este gato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CatsBloc>().add(DeleteCat(widget.catId));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
