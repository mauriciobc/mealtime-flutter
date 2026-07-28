import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:mealtime_app/features/onboarding/presentation/bloc/onboarding_state.dart';

export 'onboarding_event.dart';
export 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  /// Total navigable steps: Welcome(0), Household(1), Cats(2), Invite(3)
  static const int totalSteps = 4;

  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingNextStep>(_onNextStep);
    on<OnboardingPrevStep>(_onPrevStep);
    on<OnboardingHouseholdCreated>(_onHouseholdCreated);
    on<OnboardingHouseholdJoined>(_onHouseholdJoined);
    on<OnboardingCatAdded>(_onCatAdded);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onNextStep(OnboardingNextStep event, Emitter<OnboardingState> emit) {
    final next = state.currentStep + 1;
    if (next >= totalSteps) {
      emit(OnboardingDone(
        currentStep: state.currentStep,
        householdId: state.householdId,
        addedCats: state.addedCats,
        isJoinFlow: state.isJoinFlow,
      ));
    } else {
      emit(state.copyWith(currentStep: next));
    }
  }

  void _onPrevStep(OnboardingPrevStep event, Emitter<OnboardingState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void _onHouseholdCreated(
    OnboardingHouseholdCreated event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      householdId: event.householdId,
      currentStep: 2, // advance to Cats step
    ));
  }

  void _onHouseholdJoined(
    OnboardingHouseholdJoined event,
    Emitter<OnboardingState> emit,
  ) {
    // When joining, skip cats + invite → go directly to done
    emit(OnboardingDone(
      currentStep: state.currentStep,
      householdId: event.householdId,
      addedCats: state.addedCats,
      isJoinFlow: true,
    ));
  }

  void _onCatAdded(OnboardingCatAdded event, Emitter<OnboardingState> emit) {
    final updated = List.of(state.addedCats)..add(event.cat);
    emit(state.copyWith(addedCats: updated));
  }

  void _onCompleted(OnboardingCompleted event, Emitter<OnboardingState> emit) {
    emit(OnboardingDone(
      currentStep: state.currentStep,
      householdId: state.householdId,
      addedCats: state.addedCats,
      isJoinFlow: state.isJoinFlow,
    ));
  }
}
