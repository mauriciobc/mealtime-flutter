import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingNextStep extends OnboardingEvent {
  const OnboardingNextStep();
}

class OnboardingPrevStep extends OnboardingEvent {
  const OnboardingPrevStep();
}

class OnboardingHouseholdCreated extends OnboardingEvent {
  final String householdId;

  const OnboardingHouseholdCreated({required this.householdId});

  @override
  List<Object?> get props => [householdId];
}

class OnboardingHouseholdJoined extends OnboardingEvent {
  final String householdId;

  const OnboardingHouseholdJoined({required this.householdId});

  @override
  List<Object?> get props => [householdId];
}

class OnboardingCatAdded extends OnboardingEvent {
  final Cat cat;

  const OnboardingCatAdded({required this.cat});

  @override
  List<Object?> get props => [cat];
}

class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
