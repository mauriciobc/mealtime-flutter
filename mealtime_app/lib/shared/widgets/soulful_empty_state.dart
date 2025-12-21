import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';

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
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
              FilledButton.tonalIcon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  padding: const M3EdgeInsets.symmetric(
                    horizontal: M3SpacingToken.space24,
                    vertical: M3SpacingToken.space16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

