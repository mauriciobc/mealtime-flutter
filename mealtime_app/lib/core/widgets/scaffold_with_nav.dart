import 'package:flutter/material.dart';
import 'package:mealtime_app/shared/widgets/main_navigation_bar.dart';

/// Wrapper Scaffold que adiciona o NavigationBar persistente em todas as
/// páginas autenticadas.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MainNavigationBar(),
    );
  }
}

