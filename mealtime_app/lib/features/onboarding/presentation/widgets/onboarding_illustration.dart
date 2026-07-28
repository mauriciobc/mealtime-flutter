import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';

/// A warm, welcoming illustration area shown at the top of every onboarding step.
///
/// Tries to load `assets/images/onboarding/{illustrationKey}.png`.
/// Falls back gracefully to a large emoji + caption when the asset is not yet provided.
///
/// Drop the real illustration files into `assets/images/onboarding/` at any time
/// and they will be picked up automatically without code changes.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.illustrationKey,
    required this.accentColor,
    this.height,
  });

  /// Used to resolve `assets/images/onboarding/{illustrationKey}.png`
  final String illustrationKey;

  /// Step accent color — tints the background and placeholder text
  final Color accentColor;

  /// Defaults to 40 % of screen height when null
  final double? height;

  static const Map<String, String> _placeholderEmoji = {
    'welcome': '🐾',
    'household': '🏠',
    'cats': '🐱',
    'invite': '💌',
  };

  static const Map<String, String> _placeholderSemanticsLabel = {
    'welcome': 'Ilustração do passo de boas-vindas',
    'household': 'Ilustração do passo de residência',
    'cats': 'Ilustração do passo de gatos',
    'invite': 'Ilustração do passo de convite',
  };

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final containerHeight = height ?? _responsiveIllustrationHeight(screenHeight);
    final assetPath = 'assets/images/onboarding/$illustrationKey.png';
    final emoji = _placeholderEmoji[illustrationKey] ?? '✨';
    final semanticsLabel =
        _placeholderSemanticsLabel[illustrationKey] ?? 'Ilustração decorativa';

    final heroRadius = M3Shapes.illustrationHero;
    return Container(
      width: double.infinity,
      height: containerHeight,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.only(
          bottomLeft: heroRadius.bottomLeft,
          bottomRight: heroRadius.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: heroRadius.bottomLeft,
          bottomRight: heroRadius.bottomRight,
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _PlaceholderContent(
              emoji: emoji,
              accentColor: accentColor,
              semanticsLabel: semanticsLabel,
              compact: screenHeight < 600,
            );
          },
        ),
      ),
    );
  }

  /// Height so illustration + step content fit in viewport without forcing scroll.
  static double _responsiveIllustrationHeight(double screenHeight) {
    const minHeight = 100.0;
    final maxHeight = screenHeight * 0.35;
    final preferred = screenHeight * 0.28;
    return preferred.clamp(minHeight, maxHeight);
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({
    required this.emoji,
    required this.accentColor,
    required this.semanticsLabel,
    this.compact = false,
  });

  final String emoji;
  final Color accentColor;
  final String semanticsLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final emojiSize = compact ? 56.0 : 96.0;
    final captionSize = compact ? 11.0 : 13.0;
    return Center(
      child: Semantics(
        label: semanticsLabel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: emojiSize)),
            SizedBox(height: compact ? 8 : 12),
            Text(
              'Ilustração em breve',
              style: GoogleFonts.outfit(
                fontSize: captionSize,
                fontWeight: FontWeight.w500,
                color: accentColor,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
