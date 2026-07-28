import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:material_3_expressive/components/buttons/styles/m3e_button_decoration.dart';

class SoulfulEmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData icon;

  const SoulfulEmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.subMessage,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const M3EdgeInsets.all(M3SpacingToken.space32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            Text(
              message,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              SizedBox(height: M3SpacingToken.space8.value),
              Text(
                subMessage!,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: M3SpacingToken.space32.value),
              M3EButton.icon(
                style: M3EButtonStyle.tonal,
                size: M3EButtonSize.md,
                shape: M3EButtonShape.round,
                decoration: M3EButtonDecoration.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

