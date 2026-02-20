import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/shared/widgets/expressive_widgets.dart';
import 'package:material_design/material_design.dart';

class SummaryCardsSection extends StatelessWidget {
  const SummaryCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          return previous.cats.length != current.cats.length;
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
              if (prevIds != currIds) return true;
              // Compare content so in-place edits (amount, fedAt) trigger rebuild
              final prevSigs = prevLogs.map(_feedingLogContentSignature).toSet();
              final currSigs = currLogs.map(_feedingLogContentSignature).toSet();
              if (prevSigs != currSigs) return true;
            }

            return false;
          },
          builder: (context, feedingLogsState) {
            final catsCount = catsState is CatsLoaded ? catsState.cats.length : 0;
            final feedingLogs = _getFeedingLogsFromState(feedingLogsState);
            
            final now = DateTime.now();
            final todayCount = feedingLogs.where((feeding) {
              final feedingDate = feeding.fedAt;
              return feedingDate.year == now.year &&
                     feedingDate.month == now.month &&
                     feedingDate.day == now.day;
            }).length;
            
            double averagePortion = 0.0;
            String averagePortionText = '0g';
            if (feedingLogs.isNotEmpty) {
              final amounts = feedingLogs
                  .where((f) => f.amount != null && f.amount! > 0)
                  .map((f) => f.amount!)
                  .toList();
              if (amounts.isNotEmpty) {
                averagePortion = amounts.reduce((a, b) => a + b) / amounts.length;
                if (averagePortion.isFinite) {
                  averagePortionText = '${averagePortion.toStringAsFixed(1)}g';
                }
              }
            }
            
            String lastFeedingTime = '--:--';
            final lastFeeding = _getLastFeedingFromState(feedingLogsState);
            if (lastFeeding != null) {
              lastFeedingTime = _formatTime(lastFeeding.fedAt);
            }
            
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            return Padding(
              padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.home_last_7_days,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _AnimatedSummaryCard(
                          delay: 0,
                          child: ExpressiveSummaryCard(
                            title: context.l10n.home_total_cats,
                            value: catsCount.toString(),
                            icon: Icons.pets,
                            accentColor: Theme.of(context).colorScheme.secondary,
                            index: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: M3SpacingToken.space12.value),
                      Expanded(
                        child: _AnimatedSummaryCard(
                          delay: 100,
                          child: ExpressiveSummaryCard(
                            title: context.l10n.home_today,
                            value: todayCount.toString(),
                            icon: Icons.restaurant,
                            accentColor: Theme.of(context).colorScheme.primary,
                            hasGradient: true,
                            index: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: M3SpacingToken.space12.value),
                  Row(
                    children: [
                      Expanded(
                        child: _AnimatedSummaryCard(
                          delay: 200,
                          child: ExpressiveSummaryCard(
                            title: context.l10n.home_average_portion,
                            value: averagePortionText,
                            icon: Icons.scale,
                            accentColor: Theme.of(context).colorScheme.tertiary,
                            index: 2,
                          ),
                        ),
                      ),
                      SizedBox(width: M3SpacingToken.space12.value),
                      Expanded(
                        child: _AnimatedSummaryCard(
                          delay: 300,
                          child: ExpressiveSummaryCard(
                            title: context.l10n.home_last_time,
                            value: lastFeedingTime,
                            icon: Icons.access_time,
                            accentColor: Theme.of(context).colorScheme.error,
                            index: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Content signature for a log so buildWhen can detect in-place edits
  /// (amount or fedAt) that affect Average Portion and Last Feeding Time cards.
  static String _feedingLogContentSignature(FeedingLog log) =>
      '${log.id}|${log.amount}|${log.fedAt.millisecondsSinceEpoch}';

  // Helper methods copied from HomePage to be self-contained or reused
  List<FeedingLog> _getFeedingLogsFromState(FeedingLogsState state) {
    if (state is FeedingLogsLoaded) {
      return state.feedingLogs;
    } else if (state is FeedingLogOperationSuccess) {
      return state.feedingLogs;
    } else if (state is FeedingLogOperationInProgress) {
      return state.feedingLogs;
    }
    return [];
  }

  FeedingLog? _getLastFeedingFromState(FeedingLogsState state) {
    if (state is FeedingLogsLoaded) {
      return state.lastFeeding;
    }
    final logs = _getFeedingLogsFromState(state);
    if (logs.isEmpty) return null;
    final sorted = List<FeedingLog>.from(logs)
      ..sort((a, b) => b.fedAt.compareTo(a.fedAt));
    return sorted.first;
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _AnimatedSummaryCard extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedSummaryCard({
    required this.child,
    required this.delay,
  });

  @override
  State<_AnimatedSummaryCard> createState() => _AnimatedSummaryCardState();
}

class _AnimatedSummaryCardState extends State<_AnimatedSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
