import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/features/auth/data/repositories/simple_auth_repository.dart';
import 'package:mealtime_app/features/auth/domain/usecases/simple_login_usecase.dart'
    show SimpleLoginUseCase, SimpleRegisterUseCase, SimpleLogoutUseCase, SimpleGetCurrentUserUseCase;
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';

// Helper function to create a custom text theme with Outfit for headings and Atkinson Hyperlegible for body
TextTheme _createCustomTextTheme(ColorScheme colorScheme) {
  final baseTextTheme = GoogleFonts.atkinsonHyperlegibleTextTheme();
  
  // Use Outfit for headings
  final outfitHeadings = GoogleFonts.outfitTextTheme(baseTextTheme);
  
  return baseTextTheme.copyWith(
    displayLarge: outfitHeadings.displayLarge?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
    displayMedium: outfitHeadings.displayMedium?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
    displaySmall: outfitHeadings.displaySmall?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
    headlineLarge: outfitHeadings.headlineLarge?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
    headlineMedium: outfitHeadings.headlineMedium?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
    headlineSmall: outfitHeadings.headlineSmall?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
    titleLarge: outfitHeadings.titleLarge?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
    titleMedium: outfitHeadings.titleMedium?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
    titleSmall: outfitHeadings.titleSmall?.copyWith(fontFamily: GoogleFonts.outfit().fontFamily),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locale para formatação de datas em português
  await initializeDateFormatting('pt_BR', null);

  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar injeção de dependência
  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Esquemas de cores padrão (fallback) quando as cores dinâmicas não estão disponíveis
  static final _defaultLightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.orange,
    brightness: Brightness.light,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.orange,
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    // Criar instâncias do sistema simplificado
    final authRepository = SimpleAuthRepository();
    final loginUseCase = SimpleLoginUseCase(authRepository);
    final registerUseCase = SimpleRegisterUseCase(authRepository);
    final logoutUseCase = SimpleLogoutUseCase(authRepository);
    final getCurrentUserUseCase = SimpleGetCurrentUserUseCase(authRepository);

    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
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
            BlocProvider<HomesBloc>(
              create: (context) => sl<HomesBloc>(),
            ),
            BlocProvider<FeedingLogsBloc>(
              create: (context) => sl<FeedingLogsBloc>(),
            ),
          ],
          child: MaterialApp.router(
            title: 'MealTime',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme ?? _defaultLightColorScheme,
              textTheme: _createCustomTextTheme(
                lightColorScheme ?? _defaultLightColorScheme,
              ),
              splashFactory: InkSparkle.splashFactory,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
              textTheme: _createCustomTextTheme(
                darkColorScheme ?? _defaultDarkColorScheme,
              ),
              splashFactory: InkSparkle.splashFactory,
            ),
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
          ),
        );
      },
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
