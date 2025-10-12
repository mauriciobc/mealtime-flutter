import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/features/auth/data/repositories/simple_auth_repository.dart';
import 'package:mealtime_app/features/auth/domain/usecases/simple_login_usecase.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar injeção de dependência
  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Criar instâncias do sistema simplificado
    final authRepository = SimpleAuthRepository();
    final loginUseCase = SimpleLoginUseCase(authRepository);
    final registerUseCase = SimpleRegisterUseCase(authRepository);
    final logoutUseCase = SimpleLogoutUseCase(authRepository);
    final getCurrentUserUseCase = SimpleGetCurrentUserUseCase(authRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<SimpleAuthBloc>(
          create: (context) => SimpleAuthBloc(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
          ),
        ),
        BlocProvider<CatsBloc>(
          create: (context) => sl<CatsBloc>(),
        ),
        BlocProvider<MealsBloc>(
          create: (context) => sl<MealsBloc>(),
        ),
        BlocProvider<HomesBloc>(
          create: (context) => sl<HomesBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'MealTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.light,
          ),
          typography: Typography.material2021(),
          splashFactory: InkSparkle.splashFactory,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.dark,
          ),
          typography: Typography.material2021(),
          splashFactory: InkSparkle.splashFactory,
        ),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
