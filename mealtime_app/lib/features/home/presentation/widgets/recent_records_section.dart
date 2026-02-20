import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/home/presentation/widgets/cat_avatar.dart';

class RecentRecordsSection extends StatelessWidget {
  const RecentRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        final prevLogs = _getFeedingLogsFromState(previous);
        final currLogs = _getFeedingLogsFromState(current);
        if (prevLogs.length != currLogs.length) return true;
        final prevFirst3 = prevLogs.take(3).map((e) => e.id).toList();
        final currFirst3 = currLogs.take(3).map((e) => e.id).toList();
        return prevFirst3.length != currFirst3.length ||
            prevFirst3.toString() != currFirst3.toString();
      },
      builder: (context, state) {
        final recentFeedings =
            _getFeedingLogsFromState(state).take(3).toList();

        return Padding(
          padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.home_recent_records,
                style: Theme.of(context).textTheme.titleLargeEmphasized?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: M3SpacingToken.space12.value),
              if (recentFeedings.isNotEmpty)
                ...recentFeedings.map(
                  (feeding) => _RecentRecordItem(
                    key: ValueKey(feeding.id),
                    feeding: feeding,
                  ),
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
                      context.l10n.home_no_recent_records,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  List<FeedingLog> _getFeedingLogsFromState(FeedingLogsState state) {
    if (state is FeedingLogsLoaded) return state.feedingLogs;
    if (state is FeedingLogOperationSuccess) return state.feedingLogs;
    if (state is FeedingLogOperationInProgress) return state.feedingLogs;
    return [];
  }
}

class _RecentRecordItem extends StatelessWidget {
  const _RecentRecordItem({super.key, required this.feeding});

  final FeedingLog feeding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          final prevCat = previous.getCatById(feeding.catId);
          final currCat = current.getCatById(feeding.catId);
          if (prevCat == null || currCat == null) return true;
          return prevCat.name != currCat.name;
        }
        return false;
      },
      builder: (context, catsState) {
        Cat? cat;
        if (catsState is CatsLoaded) {
          cat = catsState.getCatById(feeding.catId);
        }

        final foodTypeText = _translateFoodType(context, feeding.foodType);
        final notSpecified = context.l10n.home_food_not_specified;
        final amountText = feeding.amount != null
            ? context.l10n.home_amount_food_type(
                feeding.amount!.toStringAsFixed(0),
                foodTypeText ?? notSpecified,
              )
            : (foodTypeText ?? notSpecified);

        return Container(
          margin: EdgeInsets.only(bottom: M3SpacingToken.space8.value),
          padding: const M3EdgeInsets.all(M3SpacingToken.space12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: M3Shapes.shapeMedium,
          ),
          child: Row(
            children: [
              cat != null
                  ? CatAvatar(cat: cat, size: 40)
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.pets,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
              SizedBox(width: M3SpacingToken.space12.value),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat?.name ?? context.l10n.home_cat_name_not_found,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      amountText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTime(feeding.fedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _translateFoodType(BuildContext context, String? foodType) {
    if (foodType == null) return null;
    switch (foodType) {
      case 'Ração Seca':
        return context.l10n.home_food_dry;
      case 'Ração Úmida':
        return context.l10n.home_food_wet;
      case 'Comida Caseira':
        return context.l10n.home_food_homemade;
      default:
        return foodType;
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
