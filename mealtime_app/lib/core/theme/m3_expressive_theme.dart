import 'package:flutter/material.dart';

class M3ExpressiveColors {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color background;
  final Color onBackground;
  final Color inverseSurface;
  final Color? inverseOnSurface;
  final Color inversePrimary;
  final Color surfaceContainerHighest;
  final Color surfaceContainerHigh;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerLowest;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceTint;
  final Color scrim;

  const M3ExpressiveColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.background,
    required this.onBackground,
    required this.inverseSurface,
    this.inverseOnSurface,
    required this.inversePrimary,
    required this.surfaceContainerHighest,
    required this.surfaceContainerHigh,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerLowest,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceTint,
    required this.scrim,
  });

  static M3ExpressiveColors fromColorScheme(ColorScheme scheme) {
    return M3ExpressiveColors(
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      primaryContainer: scheme.primaryContainer,
      onPrimaryContainer: scheme.onPrimaryContainer,
      secondary: scheme.secondary,
      onSecondary: scheme.onSecondary,
      secondaryContainer: scheme.secondaryContainer,
      onSecondaryContainer: scheme.onSecondaryContainer,
      tertiary: scheme.tertiary,
      onTertiary: scheme.onTertiary,
      tertiaryContainer: scheme.tertiaryContainer,
      onTertiaryContainer: scheme.onTertiaryContainer,
      error: scheme.error,
      onError: scheme.onError,
      errorContainer: scheme.errorContainer,
      onErrorContainer: scheme.onErrorContainer,
      surface: scheme.surface,
      onSurface: scheme.onSurface,
      surfaceVariant: scheme.surfaceContainerHighest,
      onSurfaceVariant: scheme.onSurfaceVariant,
      outline: scheme.outline,
      outlineVariant: scheme.outlineVariant,
      background: scheme.surface,
      onBackground: scheme.onSurface,
      inverseSurface: scheme.inverseSurface,
      inverseOnSurface: scheme.onInverseSurface.withValues(alpha: 0.87),
      inversePrimary: scheme.inversePrimary,
      surfaceContainerHighest: scheme.surfaceContainerHighest,
      surfaceContainerHigh: scheme.surfaceContainerHigh,
      surfaceContainer: scheme.surfaceContainer,
      surfaceContainerLow: scheme.surfaceContainerLow,
      surfaceContainerLowest: scheme.surfaceContainerLowest,
      surfaceDim: scheme.surfaceDim,
      surfaceBright: scheme.surfaceBright,
      surfaceTint: scheme.surfaceTint,
      scrim: scheme.scrim,
    );
  }

  M3ExpressiveColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? background,
    Color? onBackground,
    Color? inverseSurface,
    Color? inverseOnSurface,
    Color? inversePrimary,
    Color? surfaceContainerHighest,
    Color? surfaceContainerHigh,
    Color? surfaceContainer,
    Color? surfaceContainerLow,
    Color? surfaceContainerLowest,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceTint,
    Color? scrim,
  }) {
    return M3ExpressiveColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseOnSurface: inverseOnSurface ?? this.inverseOnSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      scrim: scrim ?? this.scrim,
    );
  }

  M3ExpressiveColors lerp(M3ExpressiveColors other, double t) {
    return M3ExpressiveColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onSecondaryContainer: Color.lerp(
        onSecondaryContainer,
        other.onSecondaryContainer,
        t,
      )!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      tertiaryContainer: Color.lerp(
        tertiaryContainer,
        other.tertiaryContainer,
        t,
      )!,
      onTertiaryContainer: Color.lerp(
        onTertiaryContainer,
        other.onTertiaryContainer,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      inverseOnSurface:
          inverseOnSurface != null && other.inverseOnSurface != null
          ? Color.lerp(inverseOnSurface, other.inverseOnSurface, t)
          : (inverseOnSurface ?? other.inverseOnSurface),
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      )!,
      surfaceContainerLowest: Color.lerp(
        surfaceContainerLowest,
        other.surfaceContainerLowest,
        t,
      )!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

class M3ExpressiveTheme extends ThemeExtension<M3ExpressiveTheme> {
  final M3ExpressiveColors colors;
  final M3ExpressiveElevation elevation;
  final M3ExpressiveBorder border;

  const M3ExpressiveTheme({
    required this.colors,
    required this.elevation,
    required this.border,
  });

  static M3ExpressiveTheme fromColorScheme(ColorScheme scheme) {
    return M3ExpressiveTheme(
      colors: M3ExpressiveColors.fromColorScheme(scheme),
      elevation: const M3ExpressiveElevation(),
      border: const M3ExpressiveBorder(),
    );
  }

  @override
  ThemeExtension<M3ExpressiveTheme> copyWith({
    M3ExpressiveColors? colors,
    M3ExpressiveElevation? elevation,
    M3ExpressiveBorder? border,
  }) {
    return M3ExpressiveTheme(
      colors: colors ?? this.colors,
      elevation: elevation ?? this.elevation,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<M3ExpressiveTheme> lerp(
    ThemeExtension<M3ExpressiveTheme>? other,
    double t,
  ) {
    if (other is! M3ExpressiveTheme) return this;
    return M3ExpressiveTheme(
      colors: colors.lerp(other.colors, t),
      elevation: elevation,
      border: border,
    );
  }
}

class M3ExpressiveElevation {
  final double level1;
  final double level2;
  final double level3;
  final double level4;
  final double level5;

  const M3ExpressiveElevation({
    this.level1 = 1.0,
    this.level2 = 2.0,
    this.level3 = 3.0,
    this.level4 = 4.0,
    this.level5 = 5.0,
  });

  static M3ExpressiveElevation get none => const M3ExpressiveElevation(
    level1: 0,
    level2: 0,
    level3: 0,
    level4: 0,
    level5: 0,
  );

  static M3ExpressiveElevation get subtle => const M3ExpressiveElevation(
    level1: 1.0,
    level2: 1.0,
    level3: 2.0,
    level4: 2.0,
    level5: 3.0,
  );

  static M3ExpressiveElevation get moderate => const M3ExpressiveElevation(
    level1: 2.0,
    level2: 3.0,
    level3: 4.0,
    level4: 5.0,
    level5: 6.0,
  );

  static M3ExpressiveElevation get expressive => const M3ExpressiveElevation(
    level1: 3.0,
    level2: 4.0,
    level3: 6.0,
    level4: 8.0,
    level5: 12.0,
  );
}

class M3ExpressiveBorder {
  final double width;
  final double widthNone;
  final double widthHairline;
  final double widthThin;
  final double widthMiddle;
  final double widthThick;

  const M3ExpressiveBorder({
    this.width = 1.0,
    this.widthNone = 0.0,
    this.widthHairline = 0.5,
    this.widthThin = 1.0,
    this.widthMiddle = 1.5,
    this.widthThick = 2.0,
  });

  static M3ExpressiveBorder get subtle => const M3ExpressiveBorder(
    width: 0.5,
    widthNone: 0.0,
    widthHairline: 0.25,
    widthThin: 0.5,
    widthMiddle: 1.0,
    widthThick: 1.5,
  );

  static M3ExpressiveBorder get expressive => const M3ExpressiveBorder(
    width: 1.0,
    widthNone: 0.0,
    widthHairline: 0.75,
    widthThin: 1.0,
    widthMiddle: 1.5,
    widthThick: 2.0,
  );
}

extension M3ExpressiveThemeExtension on ThemeData {
  M3ExpressiveTheme get expressiveTheme {
    return extension<M3ExpressiveTheme>() ??
        M3ExpressiveTheme.fromColorScheme(colorScheme);
  }
}

extension BuildContextExpressiveExtension on BuildContext {
  M3ExpressiveTheme get expressiveTheme {
    return Theme.of(this).expressiveTheme;
  }
}
