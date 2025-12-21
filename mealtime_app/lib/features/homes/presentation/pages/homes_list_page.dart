import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/home_card.dart';
import 'package:mealtime_app/services/api/homes_api_service.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:m3e_collection/m3e_collection.dart';

class HomesListPage extends StatefulWidget {
  const HomesListPage({super.key});

  @override
  State<HomesListPage> createState() => _HomesListPageState();
}

class _HomesListPageState extends State<HomesListPage> {
  // Cache de contadores de membros por household ID
  final Map<String, int> _membersCountCache = {};

  @override
  void initState() {
    super.initState();
    // Carregar households automaticamente quando a página é exibida
    context.read<HomesBloc>().add(LoadHomes());
    // Carregar contadores de membros em background
    _loadMembersCounts();
  }

  /// Carrega os contadores de membros de todos os households
  Future<void> _loadMembersCounts() async {
    try {
      final homesApi = sl<HomesApiService>();
      final householdsResponse = await homesApi.getHouseholds();
      
      if (householdsResponse.success && householdsResponse.data != null) {
        final membersCounts = <String, int>{};
        for (final household in householdsResponse.data!) {
          // Usar householdMembers (formato GET/detalhado) se disponível,
          // caso contrário usar members (formato POST/simplificado)
          final count = household.householdMembers?.length ?? 
                       household.members?.length ?? 
                       0;
          membersCounts[household.id] = count;
        }
        
        if (mounted) {
          setState(() {
            _membersCountCache.clear();
            _membersCountCache.addAll(membersCounts);
          });
        }
      }
    } catch (e) {
      // Silenciosamente falha - não é crítico para a funcionalidade principal
      debugPrint('[HomesListPage] Erro ao carregar contadores de membros: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Residências'),
        actions: [
          IconButtonM3E(
            onPressed: () {
              HapticsService.mediumImpact();
              context.push('/homes/create');
            },
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Residência',
          ),
        ],
      ),
      body: BlocConsumer<HomesBloc, HomesState>(
        listener: (context, state) {
          if (state is HomesError) {
            HapticsService.error();
          }
        },
        builder: (context, state) {
          if (state is HomesLoading) {
            return const LoadingWidget();
          } else if (state is HomesError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => context.read<HomesBloc>().add(LoadHomes()),
            );
          } else if (state is HomesLoaded) {
            if (state.homes.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildHomesList(context, state.homes);
          }
          // Estado inicial - mostrar loading enquanto carrega
          return const LoadingWidget();
        },
      ),
      floatingActionButton: FabM3E(
        icon: const Icon(Icons.add),
        onPressed: () {
          HapticsService.mediumImpact();
          context.push('/homes/create');
        },
        tooltip: 'Adicionar Residência',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          Text(
            'Nenhuma residência cadastrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: M3SpacingToken.space8.value),
          Text(
            'Adicione sua primeira residência para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: M3SpacingToken.space24.value),
          ElevatedButton.icon(
            onPressed: () {
              HapticsService.mediumImpact();
              context.push('/homes/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Residência'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomesList(BuildContext context, List<Home> homes) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticsService.mediumImpact();
        context.read<HomesBloc>().add(LoadHomes());
      },
      child: ListView.builder(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        itemCount: homes.length,
        itemBuilder: (context, index) {
          final home = homes[index];
          // Obter contador de membros do cache
          final membersCount = _membersCountCache[home.id];
          
          return Padding(
            padding: EdgeInsets.only(bottom: M3SpacingToken.space12.value),
            child: HomeCard(
              home: home,
              membersCount: membersCount,
              onTap: () => context.push('/homes/${home.id}'),
              onEdit: () => context.push('/homes/${home.id}/edit'),
              onDelete: () => _showDeleteBottomSheet(context, home),
              onSetActive: () => _setActiveHome(context, home),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteBottomSheet(BuildContext context, Home home) {
    HapticsService.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const M3EdgeInsets.all(M3SpacingToken.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                SizedBox(height: M3SpacingToken.space16.value),
                Text(
                  'Excluir Residência',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: M3SpacingToken.space8.value),
                Text(
                  'Tem certeza que deseja excluir a residência "${home.name}"?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: M3SpacingToken.space24.value),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: M3SpacingToken.space16.value),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () {
                          HapticsService.heavyImpact();
                          Navigator.of(context).pop();
                          context.read<HomesBloc>().add(DeleteHomeEvent(home.id));
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.errorContainer,
                          foregroundColor: theme.colorScheme.onErrorContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: M3Shapes.shapeXLarge,
                          ),
                        ),
                        child: const Text('Excluir'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setActiveHome(BuildContext context, Home home) {
    HapticsService.selectionClick();
    context.read<HomesBloc>().add(SetActiveHomeEvent(home.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${home.name} definida como residência ativa'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: M3Shapes.shapeMedium,
        ),
      ),
    );
  }
}
