import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
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
            
            return Padding(
              padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AnimatedSummaryCard(
                          delay: 0,
                          child: _SummaryCard(
                            title: context.l10n.home_total_cats,
                            value: catsCount.toString(),
                            icon: Icons.pets,
                            color: Theme.of(context).colorScheme.secondary,
                            subtitle: context.l10n.home_active_cats,
                          ),
                        ),
                      ),
                      SizedBox(width: M3SpacingToken.space12.value),
                      Expanded(
                        child: _AnimatedSummaryCard(
                          delay: 100,
                          child: _SummaryCard(
                            title: context.l10n.home_today,
                            value: todayCount.toString(),
                            icon: Icons.restaurant,
                            color: Theme.of(context).colorScheme.primary,
                            subtitle: context.l10n.home_feedings_title,
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
                          child: _SummaryCard(
                            title: context.l10n.home_average_portion,
                            value: averagePortionText,
                            icon: Icons.scale,
                            color: Theme.of(context).colorScheme.tertiary,
                            subtitle: context.l10n.home_average_portion_subtitle,
                          ),
                        ),
                      ),
                      SizedBox(width: M3SpacingToken.space12.value),
                      Expanded(
                        child: _AnimatedSummaryCard(
                          delay: 300,
                          child: _SummaryCard(
                            title: context.l10n.home_last_time,
                            value: lastFeedingTime,
                            icon: Icons.access_time,
                            color: Theme.of(context).colorScheme.error,
                            subtitle: context.l10n.home_last_time_subtitle,
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const M3EdgeInsets.all(M3SpacingToken.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: M3Shapes.shapeMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: M3SpacingToken.space8.value),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: M3SpacingToken.space8.value),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLargeEmphasized?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: M3SpacingToken.space4.value),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
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
