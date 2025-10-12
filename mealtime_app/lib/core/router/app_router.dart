import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/features/auth/presentation/pages/splash_page.dart';
import 'package:mealtime_app/features/auth/presentation/pages/login_page.dart';
import 'package:mealtime_app/features/auth/presentation/pages/register_page.dart';
import 'package:mealtime_app/features/auth/presentation/pages/account_page.dart';
import 'package:mealtime_app/features/home/presentation/pages/home_page.dart';
import 'package:mealtime_app/features/cats/presentation/pages/cats_list_page.dart';
import 'package:mealtime_app/features/cats/presentation/pages/create_cat_page.dart';
import 'package:mealtime_app/features/cats/presentation/pages/edit_cat_page.dart';
import 'package:mealtime_app/features/cats/presentation/pages/cat_detail_page.dart';
import 'package:mealtime_app/features/meals/presentation/pages/meals_list_page.dart';
import 'package:mealtime_app/features/meals/presentation/pages/create_meal_page.dart';
import 'package:mealtime_app/features/meals/presentation/pages/meal_detail_page.dart';
import 'package:mealtime_app/features/homes/presentation/pages/homes_list_page.dart';
import 'package:mealtime_app/features/homes/presentation/pages/create_home_page.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/cats', builder: (context, state) => const CatsListPage()),
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
      GoRoute(
        path: '/meals',
        builder: (context, state) {
          final catId = state.uri.queryParameters['catId'];
          final showTodayOnly = state.uri.queryParameters['today'] == 'true';
          return MealsListPage(catId: catId, showTodayOnly: showTodayOnly);
        },
      ),
      GoRoute(
        path: '/create-meal',
        builder: (context, state) {
          final catId = state.uri.queryParameters['catId'];
          final homeId = state.uri.queryParameters['homeId'];
          return CreateMealPage(catId: catId, homeId: homeId);
        },
      ),
      GoRoute(
        path: '/edit-meal/:mealId',
        builder: (context, state) {
          // TODO: Implementar carregamento da refeição
          return const Scaffold(
            body: Center(child: Text('EditMealPage - Em desenvolvimento')),
          );
        },
      ),
      GoRoute(
        path: '/meal-detail/:mealId',
        builder: (context, state) =>
            MealDetailPage(mealId: state.pathParameters['mealId']!),
      ),
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
          // TODO: Implementar carregamento da residência
          return const Scaffold(
            body: Center(child: Text('HomeDetailPage - Em desenvolvimento')),
          );
        },
      ),
      GoRoute(
        path: '/homes/:homeId/edit',
        builder: (context, state) {
          // TODO: Implementar carregamento da residência
          return const Scaffold(
            body: Center(child: Text('EditHomePage - Em desenvolvimento')),
          );
        },
      ),
    ],
  );

  // Constantes para facilitar navegação
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
