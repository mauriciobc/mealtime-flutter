import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/cats/presentation/widgets/cat_card.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';

class CatsListPage extends StatefulWidget {
  const CatsListPage({super.key});

  @override
  State<CatsListPage> createState() => _CatsListPageState();
}

class _CatsListPageState extends State<CatsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CatsBloc>().add(const LoadCats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Gatos'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<CatsBloc>().add(const RefreshCats());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<CatsBloc, CatsState>(
        listener: (context, state) {
          if (state is CatsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is CatOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
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
                context.read<CatsBloc>().add(const LoadCats());
              },
            );
          } else if (state is CatsLoaded) {
            if (state.cats.isEmpty) {
              return _buildEmptyState();
            }
            return _buildCatsList(state.cats);
          } else if (state is CatOperationInProgress) {
            return Stack(
              children: [
                _buildCatsList(state.cats),
                Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Material3LoadingIndicator(size: 32.0),
                            const SizedBox(height: 16),
                            Text(state.operation),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRouter.createCat);
        },
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
            Icons.pets,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum gato cadastrado',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro gato para começar!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push(AppRouter.createCat);
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Gato'),
          ),
        ],
      ),
    );
  }

  Widget _buildCatsList(List<dynamic> cats) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CatsBloc>().add(const RefreshCats());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final cat = cats[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CatCard(
              cat: cat,
              onTap: () {
                context.push('${AppRouter.catDetail}/${cat.id}');
              },
              onEdit: () {
                context.push('${AppRouter.editCat}/${cat.id}');
              },
              onDelete: () {
                _showDeleteDialog(context, cat);
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Gato'),
        content: Text('Tem certeza que deseja excluir ${cat.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CatsBloc>().add(DeleteCat(cat.id));
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
