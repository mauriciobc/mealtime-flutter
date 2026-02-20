import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/food_type.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/home/presentation/widgets/cat_avatar.dart';

class LastFeedingSection extends StatelessWidget {
  const LastFeedingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          if (previous.cats.length != current.cats.length) return true;
          final prevIds = previous.cats.map((e) => e.id).toSet();
          final currIds = current.cats.map((e) => e.id).toSet();
          return prevIds != currIds;
        }
        return false;
      },
      builder: (context, catsState) {
        return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            final prevLogs = _getFeedingLogsFromState(previous);
            final currLogs = _getFeedingLogsFromState(current);
            if (prevLogs.length != currLogs.length) return true;
            if (prevLogs.isNotEmpty && currLogs.isNotEmpty) {
              final prevIds = prevLogs.map((e) => e.id).toSet();
              final currIds = currLogs.map((e) => e.id).toSet();
              return prevIds != currIds;
            }
            return false;
          },
          builder: (context, feedingLogsState) {
            final lastFeeding = _getLastFeedingFromState(feedingLogsState);
            Cat? cat;

            if (lastFeeding != null && catsState is CatsLoaded) {
              cat = catsState.getCatById(lastFeeding.catId);
              cat ??= catsState.cats
                  .where((c) => c.id == lastFeeding.catId)
                  .firstOrNull;
              cat ??= catsState.cats.isNotEmpty ? catsState.cats.first : null;
            }

            return Padding(
              padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.home_last_feeding_title,
                    style: Theme.of(context).textTheme.titleLargeEmphasized?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: M3SpacingToken.space12.value),
                  SizedBox(
                    height: 130,
                    child: lastFeeding != null && cat != null
                        ? _FeedingCard(lastFeeding: lastFeeding, cat: cat)
                        : const _EmptyFeedingCard(),
                  ),
                ],
              ),
            );
          },
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

  FeedingLog? _getLastFeedingFromState(FeedingLogsState state) {
    if (state is FeedingLogsLoaded) return state.lastFeeding;
    final logs = _getFeedingLogsFromState(state);
    if (logs.isEmpty) return null;
    final sortedLogs = List<FeedingLog>.from(logs)
      ..sort((a, b) => b.fedAt.compareTo(a.fedAt));
    return sortedLogs.first;
  }
}

class _FeedingCard extends StatelessWidget {
  const _FeedingCard({required this.lastFeeding, required this.cat});

  final FeedingLog lastFeeding;
  final Cat cat;

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
    final fedByText = lastFeeding.fedBy == currentUserId
        ? context.l10n.home_fed_by_you
        : context.l10n.home_fed_by_other;

    final foodType = lastFeeding.foodType;
    final translatedFoodType = localizedFoodType(context, foodType);
    final amountText = lastFeeding.amount != null
        ? context.l10n.home_amount_food_type(
            lastFeeding.amount!.toStringAsFixed(0),
            translatedFoodType ?? context.l10n.home_food_dry,
          )
        : (translatedFoodType ?? context.l10n.home_food_dry);

    return Container(
      padding: const M3EdgeInsets.all(M3SpacingToken.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: M3Shapes.shapeMedium,
      ),
      child: Row(
        children: [
          CatAvatar(cat: cat, size: 60),
          SizedBox(width: M3SpacingToken.space16.value),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cat.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: M3SpacingToken.space4.value),
                Text(
                  amountText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: M3SpacingToken.space4.value),
                Text(
                  context.l10n.home_fed_by(fedByText),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: M3SpacingToken.space4.value),
                Text(
                  '${_formatTime(lastFeeding.fedAt)} · ${_formatDate(lastFeeding.fedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _EmptyFeedingCard extends StatelessWidget {
  const _EmptyFeedingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const M3EdgeInsets.all(M3SpacingToken.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: M3Shapes.shapeMedium,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: M3SpacingToken.space8.value),
            Text(
              context.l10n.home_no_feeding_recorded,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
