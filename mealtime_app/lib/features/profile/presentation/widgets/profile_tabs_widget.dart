import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/home_card.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/cats/presentation/widgets/cat_card.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:go_router/go_router.dart';

class ProfileTabsWidget extends StatelessWidget {
  final Profile profile;

  const ProfileTabsWidget({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Informações'),
              Tab(text: 'Lares'),
              Tab(text: 'Meus Gatos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildInfoTab(context),
                _buildHomesTab(context),
                _buildCatsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ProfileInfoSection(profile: profile),
    );
  }

  Widget _buildHomesTab(BuildContext context) {
    // Carregar homes apenas quando estiver no estado inicial
    final homesState = context.watch<HomesBloc>().state;
    
    if (homesState is HomesInitial) {
      // Trigger load apenas uma vez no primeiro build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomesBloc>().add(LoadHomes());
      });
    }

    return BlocBuilder<HomesBloc, HomesState>(
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma residência cadastrada',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/homes/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Residência'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomesBloc>().add(LoadHomes());
              // Aguardar até o BLoC emitir um estado terminal (loaded ou error)
              await context.read<HomesBloc>().stream
                  .skip(1) // Pular HomesLoading inicial
                  .where((s) => s is HomesLoaded || s is HomesError)
                  .first
                  .timeout(
                    const Duration(seconds: 10),
                    onTimeout: () => state,
                  );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.homes.length,
              itemBuilder: (context, index) {
                final home = state.homes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HomeCard(home: home),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCatsTab(BuildContext context) {
    // Carregar cats apenas quando estiver no estado inicial
    final catsState = context.read<CatsBloc>().state;
    
    if (catsState is CatsInitial) {
      // Trigger load apenas uma vez no primeiro build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CatsBloc>().add(const LoadCats());
      });
    }

    return BlocBuilder<CatsBloc, CatsState>(
      builder: (context, state) {
        if (state is CatsLoading) {
          return const LoadingWidget();
        } else if (state is CatsError) {
          return CustomErrorWidget(
            message: state.failure.message,
            onRetry: () => context.read<CatsBloc>().add(const LoadCats()),
          );
        } else if (state is CatsLoaded) {
          if (state.cats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum gato cadastrado',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/cats/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Gato'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CatsBloc>().add(const LoadCats());
              // Aguardar até o BLoC emitir um estado terminal (loaded ou error)
              await context.read<CatsBloc>().stream
                  .skip(1) // Pular CatsLoading inicial
                  .where((s) => s is CatsLoaded || s is CatsError)
                  .first
                  .timeout(
                    const Duration(seconds: 10),
                    onTimeout: () => state,
                  );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cats.length,
              itemBuilder: (context, index) {
                final cat = state.cats[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CatCard(cat: cat),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

