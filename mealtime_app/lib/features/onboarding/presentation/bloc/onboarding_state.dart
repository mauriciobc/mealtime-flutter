import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

class OnboardingState extends Equatable {
  /// Current step index: 0=Welcome, 1=Household, 2=Cats, 3=Invite
  final int currentStep;

  /// Household ID created during step 1 (null until created)
  final String? householdId;

  /// Cats added during step 2
  final List<Cat> addedCats;

  /// True when user joined an existing household (skips cats + invite)
  final bool isJoinFlow;

  const OnboardingState({
    this.currentStep = 0,
    this.householdId,
    this.addedCats = const [],
    this.isJoinFlow = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? householdId,
    List<Cat>? addedCats,
    bool? isJoinFlow,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      householdId: householdId ?? this.householdId,
      addedCats: addedCats ?? this.addedCats,
      isJoinFlow: isJoinFlow ?? this.isJoinFlow,
    );
  }

  @override
  List<Object?> get props => [currentStep, householdId, addedCats, isJoinFlow];
}

/// Emitted when the full onboarding flow is done — triggers navigation to /home
class OnboardingDone extends OnboardingState {
  const OnboardingDone({
    super.currentStep,
    super.householdId,
    super.addedCats,
    super.isJoinFlow,
  });
}
