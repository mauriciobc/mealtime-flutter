import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/core/widgets/scaffold_with_nav.dart';
import 'package:mealtime_app/features/auth/presentation/pages/splash_page.dart';
import 'package:mealtime_app/features/auth/presentation/pages/login_page.dart';
import 'package:mealtime_app/features/auth/presentation/pages/register_page.dart';
import 'package:mealtime_app/features/auth/presentation/pages/account_page.dart';
import 'package:mealtime_app/features/home/presentation/pages/home_page.dart';
import 'package:mealtime_app/features/cats/presentation/pages/cats_list_page.dart';
import 'package:mealtime_app/features/cats/presentation/pages/create_cat_page.dart';
import 'package:mealtime_app/features/cats/presentation/pages/edit_cat_page.dart';
import 'package:mealtime_app/features/cats/presentation/pages/cat_detail_page.dart';
// import 'package:mealtime_app/features/feeding_logs/presentation/pages/feeding_logs_list_page.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/pages/create_feeding_log_page.dart';
// import 'package:mealtime_app/features/feeding_logs/presentation/pages/feeding_log_detail_page.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/pages/homes_list_page.dart';
import 'package:mealtime_app/features/homes/presentation/pages/create_home_page.dart';
import 'package:mealtime_app/features/homes/presentation/pages/home_detail_page.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Rotas públicas (sem bottomNav)
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // Rotas autenticadas (com bottomNav persistente)
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountPage(),
          ),
          GoRoute(
            path: '/cats',
            builder: (context, state) => const CatsListPage(),
          ),
          GoRoute(
            path: '/create-cat',
            builder: (context, state) => const CreateCatPage(),
          ),
          GoRoute(
            path: '/edit-cat/:catId',
            builder: (context, state) =>
                EditCatPage(catId: state.pathParameters['catId']!),
          ),
          GoRoute(
            path: '/cat-detail/:catId',
            builder: (context, state) =>
                CatDetailPage(catId: state.pathParameters['catId']!),
          ),
          // TODO: Reativar quando FeedingLogsListPage for corrigida
          // GoRoute(
          //   path: '/feeding-logs',
          //   builder: (context, state) {
          //     return const Scaffold(
          //       body: Center(child: Text('Feeding Logs - Em desenvolvimento')),
          //     );
          //   },
          // ),
          GoRoute(
            path: '/create-feeding-log',
            builder: (context, state) {
              final catId = state.uri.queryParameters['catId'];
              final householdId = state.uri.queryParameters['householdId'];
              return CreateFeedingLogPage(
                catId: catId,
                householdId: householdId,
              );
            },
          ),
          // TODO: Descomentar quando edit e detail pages estiverem corrigidas
          // GoRoute(
          //   path: '/edit-feeding-log/:feedingLogId',
          //   builder: (context, state) {
          //     return const Scaffold(
          //       body: Center(child: Text('EditFeedingLogPage - Em desenvolvimento')),
          //     );
          //   },
          // ),
          // GoRoute(
          //   path: '/feeding-log-detail/:feedingLogId',
          //   builder: (context, state) =>
          //       FeedingLogDetailPage(mealId: state.pathParameters['feedingLogId']!),
          // ),
          GoRoute(
            path: '/homes',
            builder: (context, state) => const HomesListPage(),
          ),
          GoRoute(
            path: '/homes/create',
            builder: (context, state) => const CreateHomePage(),
          ),
          GoRoute(
            path: '/homes/:homeId',
            builder: (context, state) {
              final homeId = state.pathParameters['homeId']!;
              
              // Buscar a residência na lista de residências carregadas
              return BlocBuilder<HomesBloc, HomesState>(
                builder: (context, state) {
                  if (state is HomesLoaded) {
                    final home = state.homes.firstWhere(
                      (h) => h.id == homeId,
                      orElse: () => throw Exception(
                        'Residência não encontrada',
                      ),
                    );
                    return HomeDetailPage(home: home);
                  }
                  
                  // Se ainda não carregou, mostrar loading e carregar
                  context.read<HomesBloc>().add(LoadHomes());
                  return Scaffold(
                    body: Center(
                      child: Material3LoadingIndicator(),
                    ),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/homes/:homeId/edit',
            builder: (context, state) {
              // TODO: Implementar carregamento da residência
              return const Scaffold(
                body: Center(
                  child: Text('EditHomePage - Em desenvolvimento'),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );

  // Constantes para facilitar navegação
  static const String home = '/home';
  static const String cats = '/cats';
  static const String createCat = '/create-cat';
  static const String editCat = '/edit-cat';
  static const String catDetail = '/cat-detail';
  static const String meals = '/meals';
  static const String createMeal = '/create-meal';
  static const String editMeal = '/edit-meal';
  static const String mealDetail = '/meal-detail';
  static const String homes = '/homes';
  static const String createHome = '/homes/create';
  static const String editHome = '/homes';
  static const String homeDetail = '/homes';

  static GoRouter get router => _router;
}
