import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
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
                  lastFeeding != null && cat != null
                      ? _LastFeedingExpressiveCard(
                          lastFeeding: lastFeeding,
                          cat: cat,
                        )
                      : ExpressiveEmptyState(
                          icon: Icons.pets_outlined,
                          title: context.l10n.home_no_feeding_recorded,
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

class _LastFeedingExpressiveCard extends StatelessWidget {
  const _LastFeedingExpressiveCard({
    required this.lastFeeding,
    required this.cat,
  });

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
    final details =
        '${context.l10n.home_fed_by(fedByText)} · $amountText';
    final timeAgo =
        '${_formatTime(lastFeeding.fedAt)} · ${_formatDate(lastFeeding.fedAt)}';
    final colorScheme = Theme.of(context).colorScheme;

    return ExpressiveFeedingCard(
      avatar: CatAvatar(cat: cat, size: 56),
      catName: cat.name,
      details: details,
      timeAgo: timeAgo,
      accentColor: colorScheme.primary,
      index: 0,
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}
