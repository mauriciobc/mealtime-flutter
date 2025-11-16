import 'package:flutter/material.dart';

/// Helpers para shapes usando tokens M3 do pacote material_design
/// 
/// Este arquivo fornece shapes consistentes baseados nos tokens do Material Design 3.
/// Como o pacote material_design pode não ter tokens de border radius diretos,
/// usamos valores padrão do M3 que são comumente usados.
class M3Shapes {
  M3Shapes._();

  /// Shape pequeno (8px) - usado em chips e elementos pequenos
  static BorderRadius get shapeSmall => BorderRadius.circular(8);

  /// Shape médio (12px) - usado em inputs e cards menores
  static BorderRadius get shapeMedium => BorderRadius.circular(12);

  /// Shape grande (16px) - usado em cards principais
  static BorderRadius get shapeLarge => BorderRadius.circular(16);

  /// Shape extra grande (20px) - usado em botões de ação primária
  static BorderRadius get shapeXLarge => BorderRadius.circular(20);

  /// Shape para botões de ação primária (pill shape)
  static ShapeBorder get buttonShape => RoundedRectangleBorder(
        borderRadius: shapeXLarge,
      );

  /// Shape para cards principais
  static ShapeBorder get cardShape => RoundedRectangleBorder(
        borderRadius: shapeLarge,
      );

  /// Shape para chips
  static ShapeBorder get chipShape => RoundedRectangleBorder(
        borderRadius: shapeSmall,
      );

  /// Shape para inputs
  static ShapeBorder get inputShape => RoundedRectangleBorder(
        borderRadius: shapeMedium,
      );

  /// Shape pill (stadium) para botões de ação primária expressivos
  static ShapeBorder get buttonPillShape => const StadiumBorder();
}

