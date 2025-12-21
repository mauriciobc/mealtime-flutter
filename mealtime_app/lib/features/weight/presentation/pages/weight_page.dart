import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart' as cat_entity;
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_bloc.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_event.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_state.dart';
import 'package:mealtime_app/features/weight/presentation/widgets/add_weight_bottom_sheet.dart';
import 'package:mealtime_app/features/weight/presentation/widgets/create_goal_bottom_sheet.dart';
import 'package:mealtime_app/features/weight/presentation/widgets/weight_trend_chart.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart' as shared;
import 'package:mealtime_app/shared/widgets/cat_selection_filter.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    debugPrint('[WeightPage] 🚀 Carregando gatos...');
    context.read<CatsBloc>().add(const LoadCats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Peso'),
      ),
      body: BlocListener<CatsBloc, CatsState>(
        listener: (context, catsState) {
          debugPrint('[WeightPage] 📢 CatsBloc emitido: ${catsState.runtimeType}');
          
          List<cat_entity.Cat>? cats;
          if (catsState is CatsLoaded) {
            cats = catsState.cats;
            debugPrint('[WeightPage] ✅ CatsLoaded com ${cats.length} gatos');
          } else if (catsState is CatOperationSuccess) {
            cats = catsState.cats;
            debugPrint('[WeightPage] ✅ CatOperationSuccess com ${cats.length} gatos');
          }

          if (cats != null) {
            final weightState = context.read<WeightBloc>().state;
            debugPrint('[WeightPage] 📊 WeightBloc estado atual: ${weightState.runtimeType}');
            
            if (weightState is WeightInitial || 
                (weightState is WeightLoaded && weightState.cats.isEmpty)) {
              debugPrint('[WeightPage] 🎯 Inicializando WeightBloc com ${cats.length} gatos');
              context.read<WeightBloc>().add(
                    InitializeWeight(
                      cats: cats,
                      catId: cats.isNotEmpty ? cats.first.id : null,
                    ),
                  );
            }
          }
        },
        child: BlocBuilder<WeightBloc, WeightState>(
          builder: (context, weightState) {
            if (weightState is WeightLoading) {
              return const LoadingWidget(
                message: 'Carregando dados de peso...',
              );
            }

            if (weightState is WeightError) {
              HapticsService.error();
              return shared.CustomErrorWidget(
                message: weightState.failure.message,
                onRetry: () {
                  context.read<WeightBloc>().add(const RefreshWeightData());
                },
              );
            }

            if (weightState is WeightLoaded) {
              return _buildContent(
                weightState,
                weightState.cats,
              );
            }

            return const LoadingWidget(
              message: 'Carregando dados...',
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticsService.mediumImpact();
          final weightState = context.read<WeightBloc>().state;
          if (weightState is WeightLoaded) {
            if (weightState.selectedCat == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Selecione um gato primeiro'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: M3Shapes.shapeMedium,
                  ),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {},
                  ),
                ),
              );
              return;
            }
            
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (context) => AddWeightBottomSheet(
                selectedCat: weightState.selectedCat,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Peso'),
      ),
    );
  }

  Widget _buildContent(WeightLoaded weightState, List<cat_entity.Cat> cats) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticsService.mediumImpact();
        context.read<WeightBloc>().add(const RefreshWeightData());
      },
      child: ListView(
        key: ValueKey(
          'weight-content-${weightState.selectedCat?.id}-'
          '${weightState.filteredWeightLogs.length}-'
          '${weightState.activeGoal?.id ?? 'none'}',
        ),
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        children: <Widget>[
            // Header
            _buildHeader(weightState, cats),
            SizedBox(height: M3SpacingToken.space24.value),
            
            // Estado vazio quando não há gatos
            if (cats.isEmpty) ...[
              _buildEmptyState(),
            ],
            
            // Seletor de Gatos (se houver mais de um)
            if (cats.length > 1) ...[
              _buildCatSelector(weightState, cats),
              SizedBox(height: M3SpacingToken.space24.value),
            ],

            // Mostrar seletor quando há apenas 1 gato não selecionado
            if (cats.length == 1 && weightState.selectedCat == null) ...[
              _buildSingleCatSelector(weightState, cats.first),
              SizedBox(height: M3SpacingToken.space24.value),
            ],

            // Indicadores de Peso
            if (weightState.selectedCat != null) ...[
              RepaintBoundary(
                child: _buildWeightIndicators(weightState),
              ),
              SizedBox(height: M3SpacingToken.space24.value),
            ],

            // Progresso da Meta
            if (weightState.activeGoal != null) ...[
              RepaintBoundary(
                child: AnimatedSwitcher(
                  duration: M3Motion.standard.duration,
                  switchInCurve: M3Motion.standard.curve,
                  switchOutCurve: M3Motion.standard.curve,
                  child: _buildProgressCard(weightState),
                ),
              ),
              SizedBox(height: M3SpacingToken.space24.value),
            ],

            // Gráfico de Tendência
            if (cats.isNotEmpty) ...[
              RepaintBoundary(
                child: WeightTrendChart(
                  key: ValueKey(
                    'trend-chart-${weightState.selectedCat?.id}-'
                    '${weightState.filteredWeightLogs.length}-'
                    '${weightState.timeRangeDays}',
                  ),
                  weightLogs: weightState.filteredWeightLogs,
                  goal: weightState.activeGoal,
                  timeRangeDays: weightState.timeRangeDays,
                  onTimeRangeChanged: (days) {
                    HapticsService.selectionClick();
                    context.read<WeightBloc>().add(ChangeTimeRange(days));
                  },
                ),
              ),
              SizedBox(height: M3SpacingToken.space24.value),
            ],

            // Histórico Recente
            if (cats.isNotEmpty) ...[
              RepaintBoundary(
                child: _buildHistoryList(weightState),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildHeader(WeightLoaded weightState, List<cat_entity.Cat> cats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acompanhe a saúde do seu gato',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                    ),
              ),
            ],
          ),
        ),
        _buildNewGoalButton(weightState, cats),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const M3EdgeInsets.symmetric(vertical: M3SpacingToken.space48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            Text(
              'Nenhum gato cadastrado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: M3SpacingToken.space8.value),
            Text(
              'Adicione um gato para começar a rastrear o peso',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                  ),
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar para a página de gatos
                // context.go(AppRouter.cats);
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Gato'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewGoalButton(
    WeightLoaded weightState,
    List<cat_entity.Cat> cats,
  ) {
    final isDisabled = cats.isEmpty ||
        weightState.selectedCat == null ||
        weightState.activeGoal != null;

    return ElevatedButton.icon(
      key: const ValueKey('new-goal-button'),
      onPressed: isDisabled
          ? null
          : () {
              HapticsService.lightImpact();
              if (weightState.selectedCat == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Selecione um gato primeiro'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: M3Shapes.shapeMedium,
                    ),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  ),
                );
                return;
              }
              
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (context) => CreateGoalBottomSheet(
                  selectedCat: weightState.selectedCat!,
                  weightLogs: weightState.weightLogs,
                ),
              );
            },
      icon: const Icon(Icons.flag),
      label: const Text('Nova Meta'),
    );
  }

  Widget _buildCatSelector(WeightLoaded weightState, List<cat_entity.Cat> cats) {
    return CatSelectionFilter(
      cats: cats,
      initialSelectedId: weightState.selectedCat?.id,
      onSelected: (String? catId) {
        HapticsService.selectionClick();
        if (catId != null) {
          context.read<WeightBloc>().add(SelectCat(catId));
        } else {
          if (cats.isNotEmpty) {
            context.read<WeightBloc>().add(SelectCat(cats.first.id));
          }
        }
      },
    );
  }

  Widget _buildSingleCatSelector(WeightLoaded weightState, cat_entity.Cat cat) {
    return TweenAnimationBuilder<double>(
      duration: M3Motion.standard.duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: M3Motion.standard.curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)), // Movimento sutil M3
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticsService.lightImpact();
          context.read<WeightBloc>().add(SelectCat(cat.id));
        },
        child: AnimatedContainer(
          duration: M3Motion.standard.duration,
          curve: M3Motion.standard.curve,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const M3EdgeInsets.all(M3SpacingToken.space16),
              child: Row(
                children: [
                  _buildCatAvatar(context, cat),
                  SizedBox(width: M3SpacingToken.space16.value),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: M3SpacingToken.space4.value),
                        Text(
                          'Toque para ver os registros de peso',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightIndicators(WeightLoaded weightState) {
    return AnimatedSwitcher(
      duration: M3Motion.standard.duration,
      switchInCurve: M3Motion.standard.curve,
      switchOutCurve: M3Motion.standard.curve,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: M3Motion.standard.curve,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Row(
        key: ValueKey(
          'indicators-${weightState.selectedCat?.id}-'
          '${weightState.currentWeight?.toStringAsFixed(1) ?? 'null'}',
        ),
        children: [
          Expanded(
            child: _buildWeightCard(
              'Peso Atual',
              weightState.currentWeight != null
                  ? '${weightState.currentWeight!.toStringAsFixed(1)} kg'
                  : 'N/A',
              Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: M3SpacingToken.space16.value),
          Expanded(
            child: _buildWeightCard(
              'Meta',
              weightState.activeGoal != null
                  ? '${weightState.activeGoal!.targetWeight.toStringAsFixed(1)} kg'
                  : 'N/A',
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard(String label, String value, Color accentColor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                  ),
            ),
            SizedBox(height: M3SpacingToken.space4.value),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(WeightLoaded weightState) {
    final progress = weightState.progressPercentage ?? 0.0;
    final safeProgress = progress.isFinite ? progress : 0.0;
    
    return TweenAnimationBuilder<double>(
      duration: M3Motion.emphasized.duration,
      tween: Tween(begin: 0.0, end: safeProgress / 100),
      curve: M3Motion.emphasized.curve,
      builder: (context, animatedProgress, child) {
        return Card(
          key: ValueKey('progress-card-${weightState.activeGoal?.id ?? 'none'}'),
          child: Padding(
            padding: const M3EdgeInsets.all(M3SpacingToken.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso da Meta',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticsService.lightImpact();
                      },
                      child: const Text('Ver Dicas'),
                    ),
                  ],
                ),
                SizedBox(height: M3SpacingToken.space16.value),
                ClipRRect(
                  borderRadius: M3Shapes.shapeSmall,
                  child: LinearProgressIndicatorM3E(
                    value: animatedProgress,
                    size: LinearProgressM3ESize.m,
                    activeColor: Theme.of(context).colorScheme.primary,
                    trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                SizedBox(height: M3SpacingToken.space8.value),
                AnimatedDefaultTextStyle(
                  duration: M3Motion.standard.duration,
                  style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
                  child: Text(
                    '${(animatedProgress * 100).toStringAsFixed(0)}% completo',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildHistoryList(WeightLoaded weightState) {
    if (weightState.weightLogs.isEmpty) {
      return Card(
        child: Padding(
          padding: const M3EdgeInsets.all(M3SpacingToken.space32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.scale,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.3,
                      ),
                ),
                SizedBox(height: M3SpacingToken.space16.value),
                Text(
                  'Nenhum registro de peso',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: M3SpacingToken.space8.value),
                Text(
                  'Comece registrando o peso do seu gato',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const M3EdgeInsets.all(M3SpacingToken.space16),
            child: Text(
              'Histórico Recente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weightState.weightLogs.length > 10
                ? 10
                : weightState.weightLogs.length,
            itemBuilder: (context, index) {
              final log = weightState.weightLogs[index];
              final previousLog = index < weightState.weightLogs.length - 1
                  ? weightState.weightLogs[index + 1]
                  : null;

              double? variation;
              if (previousLog != null) {
                variation = log.weight - previousLog.weight;
              }

              return ListTile(
                key: ValueKey('weight-log-${log.id}'),
                leading: CircleAvatar(
                  backgroundColor: variation != null && variation > 0
                      ? Colors.green.withValues(alpha: 0.2)
                      : variation != null && variation < 0
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                  child: Icon(
                    variation != null && variation > 0
                        ? Icons.trending_up
                        : variation != null && variation < 0
                            ? Icons.trending_down
                            : Icons.remove,
                    color: variation != null && variation > 0
                        ? Colors.green
                        : variation != null && variation < 0
                            ? Colors.red
                            : Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text('${log.weight.toStringAsFixed(1)} kg'),
                subtitle: Text(
                  '${log.measuredAt.day}/${log.measuredAt.month}/${log.measuredAt.year} ${log.measuredAt.hour.toString().padLeft(2, '0')}:${log.measuredAt.minute.toString().padLeft(2, '0')}',
                ),
                trailing: variation != null
                    ? Container(
                        padding: const M3EdgeInsets.symmetric(
                          horizontal: M3SpacingToken.space8,
                          vertical: M3SpacingToken.space4,
                        ),
                        decoration: BoxDecoration(
                          color: variation > 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : variation < 0
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: M3Shapes.shapeMedium,
                        ),
                        child: Text(
                          '${variation > 0 ? '+' : ''}${variation.toStringAsFixed(2)} kg',
                          style: TextStyle(
                            color: variation > 0
                                ? Colors.green.shade700
                                : variation < 0
                                    ? Colors.red.shade700
                                    : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCatAvatar(BuildContext context, cat_entity.Cat cat) {
    final imageUrl = cat.imageUrl;
    final hasValidImageUrl = imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    if (hasValidImageUrl) {
      final trimmedUrl = imageUrl.trim();
      return RepaintBoundary(
        key: ValueKey('cat-avatar-${cat.id}'),
        child: SizedBox(
          width: 64,
          height: 64,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: trimmedUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 64,
                height: 64,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: CircularProgressIndicatorM3E(size: CircularProgressM3ESize.s),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 64,
                height: 64,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.pets,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      key: ValueKey('cat-avatar-fallback-${cat.id}'),
      radius: 32,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Text(
        cat.name[0].toUpperCase(),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
