import 'package:flutter/material.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';

/// Um widget que reduz sua escala ao ser pressionado, fornecendo feedback visual e tátil.
/// 
/// Usa Listener para detectar toques sem interferir na arena de gestos,
/// permitindo que funcione em conjunto com InkWell e ScrollViews.
class BouncingWidget extends StatefulWidget {
  final Widget child;
  final double scaleFactor;
  final Duration duration;
  final bool enableHaptic;

  const BouncingWidget({
    super.key,
    required this.child,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.enableHaptic = true,
  });

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enableHaptic) {
      HapticsService.lightImpact();
    }
    _controller.forward();
  }

  void _handlePointerUp(PointerUpEvent event) {
    _reverseAnimation();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _reverseAnimation();
  }

  void _reverseAnimation() {
    if (mounted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
