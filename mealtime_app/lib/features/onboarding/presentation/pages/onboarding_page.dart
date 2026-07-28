import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/onboarding_step_indicator.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/step_cats.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/step_household.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/step_invite.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/step_welcome.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateTo(int step) {
    _pageController.animateToPage(
      step,
      duration: M3Animation.durationMedium2,
      curve: M3Animation.emphasizedCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => OnboardingBloc(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingDone) {
            context.read<HomesBloc>().add(LoadHomes());
            context.go('/home');
            return;
          }
          _animateTo(state.currentStep);
        },
        builder: (context, state) {
          final step = state.currentStep;
          final scheme = Theme.of(context).colorScheme;
          final accentColors = [
            scheme.primary,
            scheme.secondary,
            scheme.tertiary,
            scheme.primary,
          ];
          final onAccentColors = [
            scheme.onPrimary,
            scheme.onSecondary,
            scheme.onTertiary,
            scheme.onPrimary,
          ];
          final stepClamped = step.clamp(0, 3);
          final accentColor = accentColors[stepClamped];
          final onAccentColor = onAccentColors[stepClamped];

          return Scaffold(
            backgroundColor: scheme.surface,
            body: SafeArea(
              child: Column(
                children: [
                  // ── Top app bar ───────────────────────────────────
                  _OnboardingAppBar(
                    step: step,
                    accentColor: accentColor,
                    onAccentColor: onAccentColor,
                    onBack: step > 0
                        ? () => context
                            .read<OnboardingBloc>()
                            .add(const OnboardingPrevStep())
                        : null,
                  ),

                  // ── Page content ──────────────────────────────────
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Step 0 — Welcome
                        StepWelcome(
                          accentColor: accentColors[0],
                          onAccentColor: onAccentColors[0],
                        ),

                        // Step 1 — Household
                        StepHousehold(
                          accentColor: accentColors[1],
                          onAccentColor: onAccentColors[1],
                        ),

                        // Step 2 — Cats
                        StepCats(
                          accentColor: accentColors[2],
                          onAccentColor: onAccentColors[2],
                          householdId: state.householdId ?? '',
                        ),

                        // Step 3 — Invite
                        StepInvite(
                          accentColor: accentColors[3],
                          onAccentColor: onAccentColors[3],
                          householdId: state.householdId ?? '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingAppBar extends StatelessWidget {
  const _OnboardingAppBar({
    required this.step,
    required this.accentColor,
    required this.onAccentColor,
    this.onBack,
  });

  final int step;
  final Color accentColor;
  final Color onAccentColor;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Back button — hidden on Welcome screen
          SizedBox(
            width: 48,
            child: onBack != null
                ? M3EIconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: accentColor),
                    onPressed: onBack,
                    tooltip: 'Voltar',
                  )
                : const SizedBox.shrink(),
          ),

          // Step indicator — hidden on Welcome screen (step 0)
          Expanded(
            child: Center(
              child: AnimatedOpacity(
                duration: M3Animation.durationShort4,
                opacity: step == 0 ? 0.0 : 1.0,
                child: OnboardingStepIndicator(
                  currentStep: step,
                  accentColor: accentColor,
                  onAccentColor: onAccentColor,
                ),
              ),
            ),
          ),

          // Spacer to balance the back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
