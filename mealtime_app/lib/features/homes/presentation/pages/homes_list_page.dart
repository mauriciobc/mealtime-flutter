import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/home_card.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:m3e_collection/m3e_collection.dart';

class HomesListPage extends StatefulWidget {
  const HomesListPage({super.key});

  @override
  State<HomesListPage> createState() => _HomesListPageState();
}

class _HomesListPageState extends State<HomesListPage> {
  @override
  void initState() {
    super.initState();
    // Carregar households automaticamente quando a página é exibida
    context.read<HomesBloc>().add(LoadHomes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Residências'),
        actions: [
          IconButtonM3E(
            onPressed: () => context.push('/homes/create'),
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Residência',
          ),
        ],
      ),
      body: BlocBuilder<HomesBloc, HomesState>(
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
        onPressed: () => context.push('/homes/create'),
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
            onPressed: () => context.push('/homes/create'),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Residência'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomesList(BuildContext context, List<dynamic> homes) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomesBloc>().add(LoadHomes());
      },
      child: ListView.builder(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        itemCount: homes.length,
        itemBuilder: (context, index) {
          final home = homes[index];
          // Se é um HouseholdModel, podemos pegar o membersCount
          int? membersCount;
          try {
            if (home.members != null) {
              membersCount = (home.members as List).length;
            }
          } catch (e) {
            // Se não tiver members, deixa null
          }
          
          return Padding(
            padding: EdgeInsets.only(bottom: M3SpacingToken.space12.value),
            child: HomeCard(
              home: home,
              membersCount: membersCount,
              onTap: () => context.push('/homes/${home.id}'),
              onEdit: () => context.push('/homes/${home.id}/edit'),
              onDelete: () => _showDeleteDialog(context, home),
              onSetActive: () => _setActiveHome(context, home),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic home) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Residência'),
        content: Text(
          'Tem certeza que deseja excluir a residência "${home.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HomesBloc>().add(DeleteHomeEvent(home.id));
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

  void _setActiveHome(BuildContext context, dynamic home) {
    context.read<HomesBloc>().add(SetActiveHomeEvent(home.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${home.name} definida como residência ativa'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
