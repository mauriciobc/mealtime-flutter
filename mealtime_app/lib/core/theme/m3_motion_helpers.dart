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

/// Widget para animar a entrada de itens em uma lista de forma escalonada (Staggered)
/// 
/// Combina Fade e Slide para criar uma entrada suave e orgânica.
class StaggeredEntranceBuilder extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration? delay;
  final Duration? duration;
  final double slideOffset;

  const StaggeredEntranceBuilder({
    super.key,
    required this.index,
    required this.child,
    this.delay,
    this.duration,
    this.slideOffset = 50.0,
  });

  @override
  State<StaggeredEntranceBuilder> createState() => _StaggeredEntranceBuilderState();
}

class _StaggeredEntranceBuilderState extends State<StaggeredEntranceBuilder> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    final resolvedDuration = widget.duration ?? M3MotionHelpers.emphasizedDuration;
    _controller = AnimationController(
      vsync: this,
      duration: resolvedDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100), // Pequeno slide vertical
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: M3MotionHelpers.emphasizedCurve,
    ));

    final delay = widget.delay ?? const Duration(milliseconds: 50);
    final totalDelay = delay * widget.index;

    Future.delayed(totalDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
