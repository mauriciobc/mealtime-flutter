import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/core/router/app_router.dart';

/// Barra de navegação principal que permanece visível em todas as páginas
/// autenticadas do aplicativo.
class MainNavigationBar extends StatelessWidget {
  const MainNavigationBar({super.key});

  /// Calcula o índice selecionado baseado na rota atual
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    // Home (índice 0)
    if (location == '/home') {
      return 0;
    } else if (location == '/cats' || 
               location.startsWith('/cat-detail') ||
               location.startsWith('/edit-cat') ||
               location.startsWith('/create-cat')) {
      return 1;
    } else if (location == '/weight') {
      return 2;
    } else if (location == '/statistics') {
      return 3;
    } else {
      // Para outras rotas, não seleciona nenhum item ou mantém o atual
      return _getSelectedIndexFallback(location);
    }
  }

  /// Fallback para calcular o índice quando a rota não corresponde
  /// diretamente
  int _getSelectedIndexFallback(String location) {
    // Se for uma rota relacionada a gatos, retorna índice 1
    if (location.contains('cat')) {
      return 1;
    }
    // Default: retorna 0 (home)
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _getSelectedIndex(context),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.pets_outlined),
          selectedIcon: Icon(Icons.pets),
          label: 'Gatos',
        ),
        NavigationDestination(
          icon: Icon(Icons.monitor_weight_outlined),
          selectedIcon: Icon(Icons.monitor_weight),
          label: 'Peso',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Estatísticas',
        ),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRouter.home);
            break;
          case 1:
            context.go(AppRouter.cats);
            break;
          case 2:
            context.go(AppRouter.weight);
            break;
          case 3:
            context.go(AppRouter.statistics);
            break;
        }
      },
    );
  }
}

