import 'package:flutter/material.dart';
import 'package:mealtime_app/shared/widgets/expressive_navigation_bar.dart';

/// Wrapper Scaffold que adiciona o NavigationBar persistente em todas as
/// páginas autenticadas (estilo M3 Expressive).
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const ExpressiveNavigationBar(),
    );
  }
}

