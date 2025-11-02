import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';

abstract class FeedingLogsState extends Equatable {
  const FeedingLogsState();

  @override
  List<Object?> get props => [];
}

class FeedingLogsInitial extends FeedingLogsState {
  const FeedingLogsInitial();
}

class FeedingLogsLoading extends FeedingLogsState {
  const FeedingLogsLoading();
}

class FeedingLogsLoaded extends FeedingLogsState {
  final List<FeedingLog> feedingLogs;
  final FeedingLog? _lastFeeding;

  FeedingLogsLoaded({required this.feedingLogs}) 
      : _lastFeeding = feedingLogs.isNotEmpty 
          ? (List<FeedingLog>.from(feedingLogs)..sort((a, b) => b.fedAt.compareTo(a.fedAt))).first
          : null;

  // Get the most recent feeding (sorted by fedAt descending)
  FeedingLog? get lastFeeding => _lastFeeding;

  @override
  List<Object?> get props => [feedingLogs];
}

class FeedingLogLoaded extends FeedingLogsState {
  final FeedingLog meal;

  const FeedingLogLoaded({required this.meal});

  @override
  List<Object> get props => [meal];
}

class FeedingLogOperationInProgress extends FeedingLogsState {
  final String operation;
  final List<FeedingLog> feedingLogs;

  const FeedingLogOperationInProgress({required this.operation, required this.feedingLogs});

  @override
  List<Object> get props => [operation, feedingLogs];
}

class FeedingLogOperationSuccess extends FeedingLogsState {
  final String message;
  final List<FeedingLog> feedingLogs;
  final FeedingLog? updatedFeedingLog;

  const FeedingLogOperationSuccess({
    required this.message,
    required this.feedingLogs,
    this.updatedFeedingLog,
  });

  @override
  List<Object?> get props => [message, feedingLogs, updatedFeedingLog];
}

class FeedingLogsError extends FeedingLogsState {
  final Failure failure;

  const FeedingLogsError(this.failure);

  @override
  List<Object> get props => [failure];
}
