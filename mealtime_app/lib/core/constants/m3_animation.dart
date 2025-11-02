import 'package:flutter/material.dart';

/// Constantes de animação seguindo Material Design 3 Motion Tokens
/// Baseado em: https://m3.material.io/styles/motion/overview
class M3Animation {
  M3Animation._();

  // Durações padrão M3
  /// 150ms - Micro-interações rápidas (hover, focus)
  static const Duration durationShort1 = Duration(milliseconds: 150);
  
  /// 200ms - Micro-interações padrão (tap, ripple)
  static const Duration durationShort2 = Duration(milliseconds: 200);
  
  /// 250ms - Transições padrão (mostrar/esconder elementos)
  static const Duration durationShort3 = Duration(milliseconds: 250);
  
  /// 300ms - Transições de entrada/saída padrão (mobile)
  static const Duration durationShort4 = Duration(milliseconds: 300);
  
  /// 350ms - Transições médias (modais, dialogs)
  static const Duration durationMedium1 = Duration(milliseconds: 350);
  
  /// 400ms - Transições de expansão/collapse
  static const Duration durationMedium2 = Duration(milliseconds: 400);
  
  /// 500ms - Transições complexas (navegação de página)
  static const Duration durationLong1 = Duration(milliseconds: 500);

  // Curvas de easing padrão M3
  
  /// Standard easing - para a maioria das transições
  /// Usa easeInOut para movimento natural
  static const Curve standardCurve = Curves.easeInOut;
  
  /// Emphasized easing - para transições que precisam de destaque
  /// Usa easeInOutCubic para movimento mais expressivo
  static const Curve emphasizedCurve = Curves.easeInOutCubic;
  
  /// Decelerated easing - para elementos que aparecem (entrada)
  /// Começa rápido e desacelera
  static const Curve deceleratedCurve = Curves.decelerate;
  
  /// Accelerated easing - para elementos que desaparecem (saída)
  /// Começa lento e acelera
  static const Curve acceleratedCurve = Curves.fastOutSlowIn;

  /// Sharp easing - para mudanças instantâneas visuais
  static const Curve sharpCurve = Curves.easeOut;

  // Curvas animadas para uso com AnimationController
  // Nota: Não podem ser const porque CurvedAnimation não é const
  static CurvedAnimation get standardAnimation => CurvedAnimation(
    parent: const AlwaysStoppedAnimation(1.0),
    curve: standardCurve,
  );
  
  static CurvedAnimation get emphasizedAnimation => CurvedAnimation(
    parent: const AlwaysStoppedAnimation(1.0),
    curve: emphasizedCurve,
  );
  
  static CurvedAnimation get deceleratedAnimation => CurvedAnimation(
    parent: const AlwaysStoppedAnimation(1.0),
    curve: deceleratedCurve,
  );
  
  static CurvedAnimation get acceleratedAnimation => CurvedAnimation(
    parent: const AlwaysStoppedAnimation(1.0),
    curve: acceleratedCurve,
  );

  // Helper para criar CurvedAnimation dinâmica
  static CurvedAnimation createCurvedAnimation(
    Animation<double> parent,
    Curve curve,
  ) {
    return CurvedAnimation(parent: parent, curve: curve);
  }
}

/// Transições padrão M3 para uso com AnimatedSwitcher
class M3Transitions {
  M3Transitions._();

  /// Transição fade padrão - 250ms com standard easing
  static Widget fadeTransition(
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Transição scale + fade - 300ms com decelerated easing (entrada)
  static Widget scaleTransition(
    Widget child,
    Animation<double> animation,
  ) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: M3Animation.deceleratedCurve,
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Transição slide + fade - 300ms com decelerated easing
  static Widget slideTransition(
    Widget child,
    Animation<double> animation, {
    Offset begin = const Offset(0, 0.1),
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: M3Animation.deceleratedCurve,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Transição combinada slide + fade + scale (para elementos importantes)
  static Widget emphasizedTransition(
    Widget child,
    Animation<double> animation, {
    Offset begin = const Offset(0, 0.05),
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: M3Animation.emphasizedCurve,
        ),
      ),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: M3Animation.deceleratedCurve,
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}

