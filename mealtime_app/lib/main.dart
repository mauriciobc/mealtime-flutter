import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:mealtime_app/features/weight/presentation/bloc/weight_bloc.dart';

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

/// Calcula a luminância relativa de uma cor (0.0 a 1.0)
double _getLuminance(Color color) {
  return HSLColor.fromColor(color).lightness;
}

/// Verifica se duas cores têm contraste suficiente
/// Retorna true se a diferença de luminância for maior que o mínimo
bool _hasSufficientContrast(Color color1, Color color2, double minDiff) {
  final lum1 = _getLuminance(color1);
  final lum2 = _getLuminance(color2);
  return (lum1 - lum2).abs() >= minDiff;
}

/// Ajusta uma cor para ter luminância específica e reduz a saturação
/// Útil para criar cores de containers mais neutras
Color _adjustColorLightnessAndDesaturate(
  Color color,
  double targetLightness,
  double maxSaturation,
) {
  final hsl = HSLColor.fromColor(color);
  final newSaturation = hsl.saturation > maxSaturation
      ? maxSaturation
      : hsl.saturation;
  return hsl
      .withLightness(targetLightness.clamp(0.0, 1.0))
      .withSaturation(newSaturation.clamp(0.0, 1.0))
      .toColor();
}

/// Analisa e ajusta todas as cores do tema para garantir contraste adequado
/// 
/// Garante diferenças mínimas entre:
/// - surface (background) e surfaceContainerHighest
/// - surface e surfaceContainer (usado em cards)
/// - surfaceContainer e suas variantes (High, Highest)
/// 
/// No Material Design 3:
/// - Tema claro: containers são mais escuros que surface
/// - Tema escuro: containers são mais claros que surface
ColorScheme _ensureThemeColorContrast(ColorScheme colorScheme) {
  final brightness = colorScheme.brightness;
  final surface = colorScheme.surface;
  final surfaceHSL = HSLColor.fromColor(surface);
  final baseLightness = surfaceHSL.lightness;
  
  // Diferenças mínimas de luminância necessárias
  // Para cards terem contraste visível, precisamos de pelo menos 4-5%
  const minVariantDiff = 0.03; // surfaceVariant: 3% de diferença
  const minContainerDiff = 0.04; // surfaceContainer: 4% de diferença (para cards)
  const minHighDiff = 0.06; // surfaceContainerHigh: 6% de diferença
  const minHighestDiff = 0.08; // surfaceContainerHighest: 8% de diferença
  
  // Saturação máxima para containers (cores menos saturadas = mais neutras)
  const maxContainerSaturation = 0.08; // 8% de saturação máxima
  
  ColorScheme adjusted = colorScheme;
  
  // Ajusta surfaceContainerHighest (substitui surfaceVariant que está deprecated)
  if (!_hasSufficientContrast(surface, colorScheme.surfaceContainerHighest, minVariantDiff)) {
    final variantLightness = brightness == Brightness.light
        ? baseLightness - minVariantDiff
        : baseLightness + minVariantDiff;
    adjusted = adjusted.copyWith(
      surfaceContainerHighest: _adjustColorLightnessAndDesaturate(
        surface,
        variantLightness,
        maxContainerSaturation,
      ),
    );
  }
  
  // Ajusta surfaceContainer (usado em cards - precisa de mais contraste)
  // Usa cor menos saturada para ser mais neutra
  final currentContainer = adjusted.surfaceContainer;
  final currentContainerHSL = HSLColor.fromColor(currentContainer);
  final needsAdjustment = !_hasSufficientContrast(surface, currentContainer, minContainerDiff) ||
      currentContainerHSL.saturation > maxContainerSaturation;
  
  if (needsAdjustment) {
    final containerLightness = brightness == Brightness.light
        ? baseLightness - minContainerDiff
        : baseLightness + minContainerDiff;
    adjusted = adjusted.copyWith(
      surfaceContainer: _adjustColorLightnessAndDesaturate(
        surface,
        containerLightness,
        maxContainerSaturation,
      ),
    );
  }
  
  // Ajusta surfaceContainerHigh (cores menos saturadas)
  final currentHigh = adjusted.surfaceContainerHigh;
  final currentHighHSL = HSLColor.fromColor(currentHigh);
  final needsHighAdjustment = !_hasSufficientContrast(surface, currentHigh, minHighDiff) ||
      currentHighHSL.saturation > maxContainerSaturation;
  
  if (needsHighAdjustment) {
    final highLightness = brightness == Brightness.light
        ? baseLightness - minHighDiff
        : baseLightness + minHighDiff;
    adjusted = adjusted.copyWith(
      surfaceContainerHigh: _adjustColorLightnessAndDesaturate(
        surface,
        highLightness,
        maxContainerSaturation,
      ),
    );
  }
  
  // Ajusta surfaceContainerHighest (cores menos saturadas)
  final currentHighest = adjusted.surfaceContainerHighest;
  final currentHighestHSL = HSLColor.fromColor(currentHighest);
  final needsHighestAdjustment = !_hasSufficientContrast(surface, currentHighest, minHighestDiff) ||
      currentHighestHSL.saturation > maxContainerSaturation;
  
  if (needsHighestAdjustment) {
    final highestLightness = brightness == Brightness.light
        ? baseLightness - minHighestDiff
        : baseLightness + minHighestDiff;
    adjusted = adjusted.copyWith(
      surfaceContainerHighest: _adjustColorLightnessAndDesaturate(
        surface,
        highestLightness,
        maxContainerSaturation,
      ),
    );
  }
  
  return adjusted;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tratamento global de erros de renderização
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log limitado para evitar spam no console
    // AssertionError são comuns durante desenvolvimento e podem causar loops
    final exception = details.exception;
    final stack = details.stack;
    
    // Limitar logs de AssertionError relacionados a parentDataDirty e acessibilidade
    // pois esses são os que causam loops infinitos
    if (exception is AssertionError) {
      final message = exception.toString();
      if (message.contains('parentDataDirty') || 
          message.contains('semantics') ||
          message.contains('fl_view_accessible') ||
          message.contains('child != nullptr')) {
        // Não logar repetidamente o mesmo erro
        // Apenas registrar uma vez para evitar spam
        return;
      }
    }
    
    // Para outros erros, logar normalmente mas sem presentError
    // para evitar múltiplas janelas de erro
    debugPrint('[FlutterError] ${details.exception}');
    if (stack != null) {
      debugPrint('[FlutterError] Stack: ${stack.toString().split('\n').take(5).join('\n')}');
    }
  };

  // Tratamento de erros assíncronos não capturados
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[PlatformError] $error');
    debugPrint('[PlatformError] Stack: $stack');
    return true; // Indica que o erro foi tratado
  };

  // Inicializar formatos de data para locales suportados
  // Isso garante que os símbolos de data estejam disponíveis mesmo
  // se o locale do sistema mudar durante a execução
  final supportedLocales = ['pt_BR', 'en_US', 'es_ES', 'fr_FR'];
  for (final locale in supportedLocales) {
    try {
      await initializeDateFormatting(locale, null);
    } catch (e) {
      debugPrint('[Locale] Falha ao inicializar formato de data para $locale: $e');
    }
  }
  
  // Também inicializar o locale do sistema se ainda não foi inicializado
  final systemLocale = PlatformDispatcher.instance.locale;
  final systemLocaleString = systemLocale.toString();
  if (!supportedLocales.contains(systemLocaleString)) {
    try {
      await initializeDateFormatting(systemLocaleString, null);
    } catch (e) {
      debugPrint('[Locale] Locale do sistema $systemLocaleString não suportado, usando pt_BR como fallback');
    }
  }

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

  /// Constrói um ThemeData a partir de um ColorScheme
  /// Elimina duplicação entre theme e darkTheme
  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _createCustomTextTheme(colorScheme),
      splashFactory: InkSparkle.splashFactory,
      // Configura Cards para usarem surfaceContainer (com contraste)
      // em vez de surface (mesma cor do background)
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        // Ajusta os esquemas de cores para garantir contraste adequado entre todas as cores
        final adjustedLightScheme = lightColorScheme != null
            ? _ensureThemeColorContrast(lightColorScheme)
            : _ensureThemeColorContrast(_defaultLightColorScheme);
        final adjustedDarkScheme = darkColorScheme != null
            ? _ensureThemeColorContrast(darkColorScheme)
            : _ensureThemeColorContrast(_defaultDarkColorScheme);
        
        return ProviderScope(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SimpleAuthBloc>(
                create: (context) => sl<SimpleAuthBloc>(),
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
              BlocProvider<StatisticsBloc>(
                create: (context) => sl<StatisticsBloc>(),
              ),
              BlocProvider<WeightBloc>(
                create: (context) => sl<WeightBloc>(),
              ),
            ],
            child: MaterialApp.router(
              title: 'MealTime',
              debugShowCheckedModeBanner: false,
              theme: _buildTheme(adjustedLightScheme),
              darkTheme: _buildTheme(adjustedDarkScheme),
              themeMode: ThemeMode.system,
              routerConfig: AppRouter.router,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('pt', 'BR'), // Português do Brasil
                Locale('en', 'US'), // Inglês
                Locale('es', 'ES'), // Espanhol
                Locale('fr', 'FR'), // Francês
              ],
            ),
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
