import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/food_type.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/home/presentation/widgets/cat_avatar.dart';
import 'package:mealtime_app/shared/widgets/expressive_widgets.dart';

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
                ...recentFeedings.asMap().entries.map(
                      (entry) => Padding(
                        key: ValueKey(entry.value.id),
                        padding: EdgeInsets.only(
                          bottom: entry.key < recentFeedings.length - 1
                              ? M3SpacingToken.space8.value
                              : 0,
                        ),
                        child: _RecentRecordExpressiveItem(
                          feeding: entry.value,
                          index: entry.key,
                        ),
                      ),
                    )
              else
                ExpressiveEmptyState(
                  icon: Icons.history,
                  title: context.l10n.home_no_recent_records,
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

class _RecentRecordExpressiveItem extends StatelessWidget {
  const _RecentRecordExpressiveItem({
    required this.feeding,
    required this.index,
  });

  final FeedingLog feeding;
  final int index;

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
        final foodTypeText = localizedFoodType(context, feeding.foodType);
        final notSpecified = context.l10n.home_food_not_specified;
        final amountText = feeding.amount != null
            ? context.l10n.home_amount_food_type(
                feeding.amount!.toStringAsFixed(0),
                foodTypeText ?? notSpecified,
              )
            : (foodTypeText ?? notSpecified);
        final colorScheme = Theme.of(context).colorScheme;
        final avatar = cat != null
            ? CatAvatar(cat: cat, size: 44)
            : CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.pets,
                  color: colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              );

        return ExpressiveFeedingCard(
          avatar: avatar,
          catName: cat?.name ?? context.l10n.home_cat_name_not_found,
          details: amountText,
          timeAgo: _formatTime(context, feeding.fedAt),
          accentColor: colorScheme.primary,
          index: index,
        );
      },
    );
  }

  String _formatTime(BuildContext context, DateTime dt) =>
      DateFormat.jm(Localizations.localeOf(context).toString()).format(dt);
}
