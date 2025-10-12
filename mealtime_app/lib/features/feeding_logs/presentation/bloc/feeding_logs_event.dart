import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/meal.dart';

abstract class FeedingLogsEvent extends Equatable {
  const FeedingLogsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedingLogs extends FeedingLogsEvent {
  const LoadFeedingLogs();
}

class LoadFeedingLogsByCat extends FeedingLogsEvent {
  final String catId;

  const LoadFeedingLogsByCat(this.catId);

  @override
  List<Object> get props => [catId];
}

class LoadFeedingLogById extends FeedingLogsEvent {
  final String mealId;

  const LoadFeedingLogById(this.mealId);

  @override
  List<Object> get props => [mealId];
}

class LoadTodayFeedingLogs extends FeedingLogsEvent {
  const LoadTodayFeedingLogs();
}

class CreateFeedingLog extends FeedingLogsEvent {
  final FeedingLog meal;

  const CreateFeedingLog(this.meal);

  @override
  List<Object> get props => [meal];
}

class UpdateFeedingLog extends FeedingLogsEvent {
  final FeedingLog meal;

  const UpdateFeedingLog(this.meal);

  @override
  List<Object> get props => [meal];
}

class DeleteFeedingLog extends FeedingLogsEvent {
  final String mealId;

  const DeleteFeedingLog(this.mealId);

  @override
  List<Object> get props => [mealId];
}

class CompleteFeedingLog extends FeedingLogsEvent {
  final String mealId;
  final String? notes;
  final double? amount;

  const CompleteFeedingLog({required this.mealId, this.notes, this.amount});

  @override
  List<Object?> get props => [mealId, notes, amount];
}

class SkipFeedingLog extends FeedingLogsEvent {
  final String mealId;
  final String? reason;

  const SkipFeedingLog({required this.mealId, this.reason});

  @override
  List<Object?> get props => [mealId, reason];
}

class RefreshFeedingLogs extends FeedingLogsEvent {
  const RefreshFeedingLogs();
}

class ClearFeedingLogsError extends FeedingLogsEvent {
  const ClearFeedingLogsError();
}
