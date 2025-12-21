import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';

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
                  HapticsService.lightImpact();
                  context.push('/edit-cat/${widget.catId}');
                  break;
                case 'delete':
                  _showDeleteBottomSheet(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: M3SpacingToken.space8.value),
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
                    SizedBox(width: M3SpacingToken.space8.value),
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
            HapticsService.success();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            if (state.message.contains('excluído')) {
              context.pop();
            }
          } else if (state is CatsError) {
            HapticsService.error();
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
                HapticsService.lightImpact();
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

  Widget _buildCatDetails(BuildContext context, Cat cat) {
    return SingleChildScrollView(
      padding: const M3EdgeInsets.all(M3SpacingToken.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCatHeader(context, cat),
          SizedBox(height: M3SpacingToken.space24.value),
          _buildCatInfo(context, cat),
          SizedBox(height: M3SpacingToken.space24.value),
          _buildWeightSection(context, cat),
          SizedBox(height: M3SpacingToken.space24.value),
          _buildDescriptionSection(context, cat),
        ],
      ),
    );
  }

  Widget _buildCatHeader(BuildContext context, Cat cat) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Material3LoadingIndicator(size: 32.0),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                width: 80,
                height: 80,
                color: colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.pets,
                  size: 40,
                  color: colorScheme.primary,
                ),
              );
            },
          ),
        ),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 40,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.pets,
          size: 40,
          color: colorScheme.primary,
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space20),
        child: Row(
          children: [
            Hero(
              tag: 'cat_avatar_${cat.id}',
              child: avatarWidget,
            ),
            SizedBox(width: M3SpacingToken.space20.value),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (cat.breed != null) ...[
                    SizedBox(height: M3SpacingToken.space4.value),
                    Text(
                      cat.breed!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  SizedBox(height: M3SpacingToken.space8.value),
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      SizedBox(width: M3SpacingToken.space4.value),
                      Text(
                        cat.ageDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (cat.gender != null) ...[
                        SizedBox(width: M3SpacingToken.space16.value),
                        Icon(
                          cat.gender == 'M' ? Icons.male : Icons.female,
                          size: 16,
                          color: cat.gender == 'M'
                              ? colorScheme.primary
                              : colorScheme.tertiary,
                        ),
                        SizedBox(width: M3SpacingToken.space4.value),
                        Text(
                          cat.gender == 'M' ? 'Macho' : 'Fêmea',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildCatInfo(BuildContext context, Cat cat) {
    return Card(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
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

  Widget _buildWeightSection(BuildContext context, Cat cat) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peso',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            if (cat.currentWeight != null) ...[
              _buildInfoRow(
                context,
                'Peso Atual',
                '${cat.currentWeight!.toStringAsFixed(1)} kg',
              ),
              if (cat.targetWeight != null) ...[
                SizedBox(height: M3SpacingToken.space8.value),
                _buildInfoRow(
                  context,
                  'Peso Ideal',
                  '${cat.targetWeight!.toStringAsFixed(1)} kg',
                ),
                SizedBox(height: M3SpacingToken.space8.value),
                _buildWeightProgress(context, cat),
              ],
            ] else ...[
              Text(
                'Peso não informado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            SizedBox(height: M3SpacingToken.space16.value),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  HapticsService.lightImpact();
                  _showUpdateWeightBottomSheet(context, cat);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.tertiaryContainer,
                  foregroundColor: colorScheme.onTertiaryContainer,
                ),
                icon: const Icon(Icons.monitor_weight),
                label: const Text('Atualizar Peso'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightProgress(BuildContext context, Cat cat) {
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
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isOverweight = progress > 1.1;
    final isUnderweight = progress < 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicatorM3E(
          value: progress.clamp(0.0, 1.5),
          trackColor: colorScheme.surfaceContainerHighest,
          activeColor: isOverweight
              ? colorScheme.tertiary
              : isUnderweight
              ? colorScheme.primary
              : colorScheme.secondary,
        ),
        SizedBox(height: M3SpacingToken.space8.value),
        Text(
          _getWeightStatus(cat.currentWeight!, cat.targetWeight!),
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverweight
                ? colorScheme.tertiary
                : isUnderweight
                ? colorScheme.primary
                : colorScheme.secondary,
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

  Widget _buildDescriptionSection(BuildContext context, Cat cat) {
    if (cat.description == null || cat.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
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
      padding: EdgeInsets.only(bottom: M3SpacingToken.space8.value),
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

  void _showUpdateWeightBottomSheet(BuildContext context, Cat cat) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true, // Importante para o teclado
      builder: (context) => _UpdateWeightBottomSheet(
        cat: cat,
        initialWeight: cat.currentWeight,
      ),
    );
  }

  void _showDeleteBottomSheet(BuildContext context) {
    HapticsService.mediumImpact();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const M3EdgeInsets.all(M3SpacingToken.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: M3SpacingToken.space16.value),
              Text(
                'Excluir Gato',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: M3SpacingToken.space8.value),
              Text(
                'Tem certeza que deseja excluir este gato? Esta ação não pode ser desfeita.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: M3SpacingToken.space32.value),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: M3SpacingToken.space16.value),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        HapticsService.heavyImpact();
                        Navigator.of(context).pop();
                        context.read<CatsBloc>().add(DeleteCat(widget.catId));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      child: const Text('Excluir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateWeightBottomSheet extends StatefulWidget {
  final Cat cat;
  final double? initialWeight;

  const _UpdateWeightBottomSheet({
    required this.cat,
    this.initialWeight,
  });

  @override
  State<_UpdateWeightBottomSheet> createState() =>
      _UpdateWeightBottomSheetState();
}

class _UpdateWeightBottomSheetState extends State<_UpdateWeightBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  String? _validateWeight(String? value) {
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
    if (weight > 50.0) {
      return 'Peso deve ser no máximo 50.0 kg';
    }
    // Validação adicional: verificar se há muitos dígitos decimais
    final parts = normalizedValue.split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Use no máximo 2 casas decimais';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticsService.error();
      return;
    }

    final normalizedValue =
        _weightController.text.replaceAll(',', '.').trim();
    final weight = double.parse(normalizedValue);

    await HapticsService.mediumImpact();
    context.read<CatsBloc>().add(UpdateCatWeight(widget.cat.id, weight));

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atualizar Peso',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: M3SpacingToken.space8.value),
              Text(
                'Informe o novo peso de ${widget.cat.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: M3SpacingToken.space24.value),
              TextFormField(
                controller: _weightController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'Ex: 5.5',
                  border: OutlineInputBorder(),
                  suffixText: 'kg',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                validator: _validateWeight,
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
              SizedBox(height: M3SpacingToken.space32.value),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: M3SpacingToken.space16.value),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleSubmit,
                      child: const Text('Atualizar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
