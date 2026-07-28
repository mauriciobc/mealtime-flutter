import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:material_3_expressive/components/buttons/styles/m3e_button_decoration.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/onboarding_illustration.dart';

class StepWelcome extends StatefulWidget {
  const StepWelcome({
    super.key,
    required this.accentColor,
    required this.onAccentColor,
  });

  final Color accentColor;
  final Color onAccentColor;

  @override
  State<StepWelcome> createState() => _StepWelcomeState();
}

class _StepWelcomeState extends State<StepWelcome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroController;
  late final Animation<double> _heroAnimation;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      duration: M3Animation.durationLong1,
      vsync: this,
    );
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: M3Animation.deceleratedCurve,
    );
    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        OnboardingIllustration(
          illustrationKey: 'welcome',
          accentColor: widget.accentColor,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: M3SpacingToken.space24.value,
              vertical: M3SpacingToken.space32.value,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _heroController,
                  builder: (context, child) {
                    return M3Transitions.emphasizedTransition(
                      child!,
                      _heroAnimation,
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo ao\nMealTime! 🎉',
                        style: textTheme.headlineLargeEmphasized?.copyWith(
                          height: 1.2,
                          color: widget.accentColor,
                        ),
                      ),
                      SizedBox(height: M3SpacingToken.space16.value),
                      Text(
                        'Organize a alimentação dos seus gatos com carinho. '
                        'Vamos configurar sua conta em poucos passos.',
                        style: textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: M3SpacingToken.space32.value),
                      _FeatureRow(
                        emoji: '🏠',
                        label: 'Crie sua residência',
                        accentColor: widget.accentColor,
                      ),
                      SizedBox(height: M3SpacingToken.space16.value),
                      _FeatureRow(
                        emoji: '🐱',
                        label: 'Cadastre seus gatos',
                        accentColor: widget.accentColor,
                      ),
                      SizedBox(height: M3SpacingToken.space16.value),
                      _FeatureRow(
                        emoji: '💌',
                        label: 'Convide quem você ama',
                        accentColor: widget.accentColor,
                      ),
                      SizedBox(height: M3SpacingToken.space32.value),
                      SizedBox(
                        width: double.infinity,
                        child: M3EButton(
                          style: M3EButtonStyle.filled,
                          size: M3EButtonSize.md,
                          shape: M3EButtonShape.round,
                          decoration: M3EButtonDecoration.styleFrom(
                            backgroundColor: widget.accentColor,
                            foregroundColor: widget.onAccentColor,
                          ),
                          onPressed: () => context
                              .read<OnboardingBloc>()
                              .add(const OnboardingNextStep()),
                          child: Text(
                            'Começar',
                            style: textTheme.titleLargeEmphasized,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.emoji,
    required this.label,
    required this.accentColor,
  });

  final String emoji;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: M3Shapes.shapeMedium,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        SizedBox(width: M3SpacingToken.space16.value),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
