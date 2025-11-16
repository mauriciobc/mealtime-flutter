import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';

/// Helpers para animações usando tokens M3 Motion do pacote material_design
/// 
/// Este arquivo fornece wrappers convenientes para usar os tokens de motion
/// do Material Design 3, garantindo consistência em todas as animações.
class M3MotionHelpers {
  M3MotionHelpers._();

  /// Retorna a duração padrão para animações standard
  static Duration get standardDuration => M3Motion.standard.duration;

  /// Retorna a curva padrão para animações standard
  static Curve get standardCurve => M3Motion.standard.curve;

  /// Retorna a duração para animações enfatizadas
  static Duration get emphasizedDuration => M3Motion.emphasized.duration;

  /// Retorna a curva para animações enfatizadas
  static Curve get emphasizedCurve => M3Motion.emphasized.curve;

  /// Cria um AnimationController com duração padrão
  static AnimationController createStandardController({
    required TickerProvider vsync,
    double? value,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: standardDuration,
      value: value,
    );
  }

  /// Cria um AnimationController com duração enfatizada
  static AnimationController createEmphasizedController({
    required TickerProvider vsync,
    double? value,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: emphasizedDuration,
      value: value,
    );
  }

  /// Cria uma CurvedAnimation com curva padrão
  static CurvedAnimation createStandardCurvedAnimation(
    Animation<double> parent,
  ) {
    return CurvedAnimation(
      parent: parent,
      curve: standardCurve,
    );
  }

  /// Cria uma CurvedAnimation com curva enfatizada
  static CurvedAnimation createEmphasizedCurvedAnimation(
    Animation<double> parent,
  ) {
    return CurvedAnimation(
      parent: parent,
      curve: emphasizedCurve,
    );
  }
}

