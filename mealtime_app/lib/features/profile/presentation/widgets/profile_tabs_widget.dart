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
    final homesState = context.read<HomesBloc>().state;
    
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
              // Capturar o estado atual ANTES de disparar o evento
              final bloc = context.read<HomesBloc>();
              final currentState = bloc.state;
              final isCurrentlyLoading = currentState is HomesLoading;
              
              // Disparar o evento de carregamento
              bloc.add(LoadHomes());
              
              // Aguardar o estado terminal apropriado baseado no estado atual
              try {
                if (isCurrentlyLoading) {
                  // Se já estamos em loading, o LoadHomes() vai emitir outro HomesLoading
                  // Aguardar o próximo estado terminal (pode ser da requisição anterior
                  // que terminar primeiro, ou da nossa se terminar primeiro)
                  // Em ambos os casos, receberemos um estado atualizado
                  await bloc.stream
                      .where((s) => s is HomesLoaded || s is HomesError)
                      .first
                      .timeout(
                        const Duration(seconds: 10),
                        onTimeout: () => state,
                      );
                  
                  // Se ainda houver um HomesLoading após o terminal (do nosso evento),
                  // aguardar o terminal da nossa requisição também
                  final nextState = bloc.state;
                  if (nextState is HomesLoading) {
                    await bloc.stream
                        .where((s) => s is HomesLoaded || s is HomesError)
                        .first
                        .timeout(
                          const Duration(seconds: 10),
                          onTimeout: () => state,
                        );
                  }
                } else {
                  // Se não estamos em loading, o LoadHomes() sempre emite HomesLoading primeiro
                  // Aguardar o primeiro HomesLoading que aparecer (será do nosso evento)
                  await bloc.stream
                      .where((s) => s is HomesLoading)
                      .first
                      .timeout(
                        const Duration(seconds: 2),
                        onTimeout: () => state,
                      );
                  
                  // Agora aguardar o estado terminal após o loading
                  await bloc.stream
                      .where((s) => s is HomesLoaded || s is HomesError)
                      .first
                      .timeout(
                        const Duration(seconds: 10),
                        onTimeout: () => state,
                      );
                }
              } catch (e) {
                // Em caso de erro, manter o estado atual
                // O timeout já retorna o estado, então não precisamos fazer nada
              }
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
              final currentState = context.read<CatsBloc>().state;
              context.read<CatsBloc>().add(const LoadCats());
              
              // Se já estamos em loading, aguardar o próximo estado terminal
              // Caso contrário, aguardar até aparecer um estado terminal
              // após o CatsLoading que será emitido pelo nosso LoadCats
              if (currentState is CatsLoading) {
                await context.read<CatsBloc>().stream
                    .where((s) => s is CatsLoaded || s is CatsError)
                    .first
                    .timeout(
                      const Duration(seconds: 10),
                      onTimeout: () => state,
                    );
              } else {
                // Aguardar até que apareça um estado terminal após o Loading
                // que será emitido pelo nosso LoadCats
                await context.read<CatsBloc>().stream
                    .skipWhile((s) => s == currentState)
                    .where((s) => s is CatsLoaded || s is CatsError)
                    .first
                    .timeout(
                      const Duration(seconds: 10),
                      onTimeout: () => state,
                    );
              }
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

