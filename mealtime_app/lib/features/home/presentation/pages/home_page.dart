import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_event.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_state.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/meals/domain/entities/meal.dart';
import 'package:mealtime_app/features/meals/presentation/widgets/feeding_bottom_sheet.dart';
import 'package:mealtime_app/features/meals/presentation/view_models/meal_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
    context.read<CatsBloc>().add(LoadCats());
    context.read<MealsBloc>().add(LoadMeals());
    context.read<HomesBloc>().add(LoadHomes());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleAuthBloc, SimpleAuthState>(
      listener: (context, state) {
        if (state is SimpleAuthInitial) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSummaryCards(context),
                const SizedBox(height: 24),
                _buildLastFeedingSection(context),
                const SizedBox(height: 24),
                _buildFeedingsChartSection(context),
                const SizedBox(height: 24),
                _buildRecentRecordsSection(context),
                const SizedBox(height: 24),
                _buildMyCatsSection(context),
                const SizedBox(height: 80), // Espaço para a navegação inferior
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showFeedingBottomSheet,
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MealTime',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  // TODO: Implementar notificações
                },
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      builder: (context, catsState) {
        return BlocBuilder<MealsBloc, MealsState>(
          builder: (context, mealsState) {
            final catsCount = catsState is CatsLoaded ? catsState.cats.length : 0;
            final todayMeals = mealsState is MealsLoaded
                ? mealsState.meals.where((vm) => vm.meal.isToday).length
                : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard('Total de Gatos', catsCount.toString())),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryCard('Alimentações Hoje', todayMeals.toString())),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard('Porção Média', '9.2g')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryCard('Última Vez', '19:28')),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastFeedingSection(BuildContext context) {
    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        MealViewModel? lastMealViewModel;
        if (state is MealsLoaded && state.meals.isNotEmpty) {
          final completedMeals = state.meals
              .where((vm) => vm.meal.status == MealStatus.completed)
              .toList();
          if (completedMeals.isNotEmpty) {
            completedMeals.sort((a, b) =>
                b.meal.completedAt!.compareTo(a.meal.completedAt!));
            lastMealViewModel = completedMeals.first;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Última Alimentação',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              if (lastMealViewModel != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.pets,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Negresco', // TODO: Buscar nome do gato
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lastMealViewModel.meal.amount?.toStringAsFixed(0) ?? '10'}g ${lastMealViewModel.meal.foodType ?? 'ração seca'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Por Maurício Castro · ${_formatTime(lastMealViewModel.meal.completedAt!)} · ${_formatDate(lastMealViewModel.meal.completedAt!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Nenhuma alimentação registrada hoje',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRouter.meals),
                  child: Text(
                    'Ver todas',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedingsChartSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alimentações',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Últimos 7 dias',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Center(
              child: Text(
                'Gráfico de alimentações\n(Em desenvolvimento)',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Dom',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('Seg',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('Ter',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('Qua',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('Qui',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('Sex',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('Sáb',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecordsSection(BuildContext context) {
    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        List<MealViewModel> recentMeals = [];
        if (state is MealsLoaded) {
          recentMeals = state.meals
              .where((vm) => vm.meal.status == MealStatus.completed)
              .take(3)
              .toList();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registros Recentes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              if (recentMeals.isNotEmpty)
                ...recentMeals.map((vm) => _buildRecentRecordItem(vm.meal))
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Nenhum registro recente',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentRecordItem(Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.pets,
                color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Negresco', // TODO: Buscar nome do gato
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  '${meal.amount?.toStringAsFixed(0) ?? '10'}g ${meal.foodType ?? 'ração seca'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(meal.completedAt ?? meal.scheduledAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCatsSection(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      builder: (context, state) {
        List<Cat> cats = [];
        if (state is CatsLoaded) {
          cats = state.cats.take(3).toList();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meus Gatos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              if (cats.isNotEmpty)
                ...cats.map((cat) => _buildMyCatsItem(cat))
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Nenhum gato cadastrado',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRouter.cats),
                  child: Text(
                    'Ver todos os gatos',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyCatsItem(Cat cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.pets,
                color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  '${cat.currentWeight?.toStringAsFixed(1) ?? '4.5'}kg',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0, // Home está ativo
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.pets_outlined),
          selectedIcon: Icon(Icons.pets),
          label: 'Gatos',
        ),
        NavigationDestination(
          icon: Icon(Icons.home_work_outlined),
          selectedIcon: Icon(Icons.home_work),
          label: 'Domicílios',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Agenda',
        ),
        NavigationDestination(
          icon: Icon(Icons.monitor_weight_outlined),
          selectedIcon: Icon(Icons.monitor_weight),
          label: 'Peso',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Estatísticas',
        ),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            // Já estamos na home
            break;
          case 1:
            context.push(AppRouter.cats);
            break;
          case 2:
            context.push(AppRouter.homes);
            break;
          case 3:
            context.push(AppRouter.meals);
            break;
          case 4:
          case 5:
            // TODO: Implementar páginas de peso e estatísticas
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Em breve!')),
            );
            break;
        }
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  void _showFeedingBottomSheet() {
    final catsBloc = context.read<CatsBloc>();
    final catsState = catsBloc.state;

    if (catsState is! CatsLoaded || catsState.cats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum gato cadastrado. Cadastre um gato primeiro.'),
        ),
      );
      return;
    }

    // Pegar householdId do primeiro gato (assumindo mesmo household)
    final householdId = catsState.cats.first.homeId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: FeedingBottomSheet(
          availableCats: catsState.cats,
          householdId: householdId,
        ),
      ),
    );
  }
}
