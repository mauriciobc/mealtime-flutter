import 'package:flutter/services.dart';

/// Serviço centralizado para feedback tátil (Haptics).
/// 
/// O objetivo é fornecer uma experiência tátil consistente e "crocante" em todo o app.
/// Use métodos semânticos em vez de chamar HapticFeedback diretamente.
class HapticsService {
  HapticsService._();

  /// Feedback leve para interações de toque simples (botões, tiles).
  /// Sensação: "Click" suave.
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Feedback médio para ações mais significativas (abrir modal, toggle importante).
  /// Sensação: "Tock" firme.
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Feedback pesado para ações destrutivas ou mudanças de estado maiores.
  /// Sensação: "Thud" pesado.
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Feedback de seleção para scroll de pickers ou sliders.
  /// Sensação: "Tick" muito leve e rápido.
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Feedback de sucesso.
  /// Sensação: Pequena vibração dupla ou longa suave.
  static Future<void> success() async {
    // No Android/iOS, vibration pode ser usada para sucesso se o device suportar padrões
    // Mas HapticFeedback padrão não tem "success/error" explícito além dos impacts.
    // Vamos simular um "double tap" leve para sucesso se necessário, 
    // ou usar mediumImpact que é satisfatório.
    // Alternativamente, podemos usar SystemSound se quisermos som também, mas aqui é só Haptics.
    
    await HapticFeedback.mediumImpact();
  }

  /// Feedback de erro.
  /// Sensação: Vibração dupla rápida e desagradável.
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}

