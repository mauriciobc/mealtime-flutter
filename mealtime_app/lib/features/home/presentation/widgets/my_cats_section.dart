import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/home/presentation/widgets/cat_avatar.dart';

class MyCatsSection extends StatelessWidget {
  const MyCatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          final prevIds = previous.cats.take(3).map((e) => e.id).toList();
          final currIds = current.cats.take(3).map((e) => e.id).toList();
          if (prevIds.length != currIds.length) return true;
          for (int i = 0; i < prevIds.length; i++) {
            if (prevIds[i] != currIds[i]) return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        final cats = state is CatsLoaded ? state.cats.take(3).toList() : <Cat>[];

        return Padding(
          padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.home_my_cats,
                style: Theme.of(context).textTheme.titleLargeEmphasized?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: M3SpacingToken.space12.value),
              if (cats.isNotEmpty)
                ...cats.map(
                  (cat) => _CatItem(key: ValueKey(cat.id), cat: cat),
                )
              else
                Container(
                  padding: const M3EdgeInsets.all(M3SpacingToken.space16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: M3Shapes.shapeMedium,
                  ),
                  child: Center(
                    child: Text(
                      context.l10n.home_no_cats_registered,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: M3SpacingToken.space8.value),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRouter.cats),
                  child: Text(
                    context.l10n.home_see_all_cats,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatItem extends StatelessWidget {
  const _CatItem({super.key, required this.cat});

  final Cat cat;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: M3SpacingToken.space8.value),
      padding: const M3EdgeInsets.all(M3SpacingToken.space12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: M3Shapes.shapeMedium,
      ),
      child: Row(
        children: [
          CatAvatar(cat: cat, size: 40),
          SizedBox(width: M3SpacingToken.space12.value),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  context.l10n.home_cat_weight(
                    cat.currentWeight?.toStringAsFixed(1) ?? '4.5',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
