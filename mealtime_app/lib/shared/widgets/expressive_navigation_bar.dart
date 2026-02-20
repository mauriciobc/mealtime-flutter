import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';

class ExpressiveNavigationBar extends StatefulWidget {
  const ExpressiveNavigationBar({super.key});

  @override
  State<ExpressiveNavigationBar> createState() =>
      _ExpressiveNavigationBarState();
}

class _ExpressiveNavigationBarState extends State<ExpressiveNavigationBar> {
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

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
      return _getSelectedIndexFallback(location);
    }
  }

  int _getSelectedIndexFallback(String location) {
    if (location.contains('cat')) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = _getSelectedIndex(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(M3Shapes.shapeLarge.topLeft.x),
          topRight: Radius.circular(M3Shapes.shapeLarge.topRight.x),
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.6),
        backgroundColor: Colors.transparent,
        elevation: 0,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(Icons.home, color: colorScheme.primary),
            label: context.l10n.navigation_home,
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/images/cat-outline.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                selectedIndex == 1
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/images/cat-bold.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            label: context.l10n.navigation_cats,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.monitor_weight_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.monitor_weight,
              color: colorScheme.primary,
            ),
            label: context.l10n.navigation_weight,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(Icons.bar_chart, color: colorScheme.primary),
            label: context.l10n.navigation_statistics,
          ),
        ],
        onDestinationSelected: (index) {
          _navigateToDestination(index, context);
        },
      ),
    );
  }

  void _navigateToDestination(int index, BuildContext context) {
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
  }
}
