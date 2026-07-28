import 'package:flutter/material.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';

/// Animated numbered step indicator for the onboarding flow.
///
/// Shows steps 1–3 (Household, Cats, Invite). Step 0 (Welcome) has no indicator.
/// The active step shows a filled circle with a white label; past steps show a
/// filled check; future steps show an outlined circle.
class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.accentColor,
    required this.onAccentColor,
  });

  /// Current onboarding step index (0=Welcome, 1=Household, 2=Cats, 3=Invite)
  final int currentStep;

  /// Active step accent color
  final Color accentColor;

  /// Color for content on accent (e.g. icon/text inside filled dot)
  final Color onAccentColor;

  static const int _totalIndicatorSteps = 3; // steps 1–3

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_totalIndicatorSteps * 2 - 1, (i) {
        if (i.isOdd) return _buildConnector(context, i ~/ 2 + 1, colorScheme);
        final stepIndex = i ~/ 2 + 1; // maps widget index → step 1/2/3
        return _buildDot(stepIndex);
      }),
    );
  }

  Widget _buildDot(int stepIndex) {
    final isPast = currentStep > stepIndex;
    final isActive = currentStep == stepIndex;

    return AnimatedContainer(
      duration: M3Animation.durationShort4,
      curve: M3Animation.standardCurve,
      width: isActive ? 36 : 28,
      height: isActive ? 36 : 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPast || isActive ? accentColor : Colors.transparent,
        border: Border.all(
          color: accentColor,
          width: isActive ? 0 : 2,
        ),
      ),
      child: Center(
        child: isPast
            ? Icon(Icons.check, color: onAccentColor, size: 14)
            : Text(
                '$stepIndex',
                style: TextStyle(
                  fontSize: isActive ? 15 : 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? onAccentColor : accentColor,
                ),
              ),
      ),
    );
  }

  Widget _buildConnector(
    BuildContext context,
    int afterStepIndex,
    ColorScheme colorScheme,
  ) {
    final isPast = currentStep > afterStepIndex;
    return AnimatedContainer(
      duration: M3Animation.durationShort4,
      curve: M3Animation.standardCurve,
      width: 24,
      height: 2,
      color: isPast ? accentColor : colorScheme.outline,
    );
  }
}
