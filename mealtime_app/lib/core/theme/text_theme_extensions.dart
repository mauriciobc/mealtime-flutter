import 'package:flutter/material.dart';

/// Extension para TextTheme que adiciona estilos enfatizados do M3 Expressive
/// 
/// Estes estilos usam fontWeight mais pesado e tamanhos maiores para criar
/// hierarquia visual e chamar atenção para ações importantes.
extension TextThemeEmphasized on TextTheme {
  /// Display Large enfatizado - para títulos principais muito importantes
  TextStyle? get displayLargeEmphasized {
    final base = displayLarge;
    if (base == null) return null;
    return base.copyWith(
      fontSize: (base.fontSize ?? 57) * 1.15, // 15% maior
      fontWeight: FontWeight.w800,
      letterSpacing: (base.letterSpacing ?? -0.25) * 0.8,
    );
  }

  /// Headline Large enfatizado - para títulos de seção importantes
  TextStyle? get headlineLargeEmphasized {
    final base = headlineLarge;
    if (base == null) return null;
    return base.copyWith(
      fontSize: (base.fontSize ?? 32) * 1.2, // 20% maior
      fontWeight: FontWeight.w700,
      letterSpacing: (base.letterSpacing ?? 0) * 0.9,
    );
  }

  /// Headline Medium enfatizado - para subtítulos importantes
  TextStyle? get headlineMediumEmphasized {
    final base = headlineMedium;
    if (base == null) return null;
    return base.copyWith(
      fontSize: (base.fontSize ?? 28) * 1.15, // 15% maior
      fontWeight: FontWeight.w700,
      letterSpacing: (base.letterSpacing ?? 0) * 0.9,
    );
  }

  /// Title Large enfatizado - para títulos de cards e CTAs
  TextStyle? get titleLargeEmphasized {
    final base = titleLarge;
    if (base == null) return null;
    return base.copyWith(
      fontSize: (base.fontSize ?? 22) * 1.18, // 18% maior
      fontWeight: FontWeight.w700,
      letterSpacing: (base.letterSpacing ?? 0) * 0.95,
    );
  }

  /// Title Medium enfatizado - para labels importantes
  TextStyle? get titleMediumEmphasized {
    final base = titleMedium;
    if (base == null) return null;
    return base.copyWith(
      fontSize: (base.fontSize ?? 16) * 1.15, // 15% maior
      fontWeight: FontWeight.w600,
      letterSpacing: (base.letterSpacing ?? 0.15) * 0.9,
    );
  }

  /// Body Large enfatizado - para texto corrido importante
  TextStyle? get bodyLargeEmphasized {
    final base = bodyLarge;
    if (base == null) return null;
    return base.copyWith(
      fontSize: (base.fontSize ?? 16) * 1.1, // 10% maior
      fontWeight: FontWeight.w600,
      letterSpacing: (base.letterSpacing ?? 0.5) * 0.9,
    );
  }
}

