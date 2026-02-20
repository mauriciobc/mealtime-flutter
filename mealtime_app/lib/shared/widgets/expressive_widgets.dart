import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';

class ExpressiveSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? accentColor;
  final bool hasGradient;
  final int index;
  final VoidCallback? onTap;

  const ExpressiveSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.accentColor,
    this.hasGradient = false,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = this.accentColor ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: hasGradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.1),
                    accentColor.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: hasGradient ? null : colorScheme.surfaceContainer,
          borderRadius: M3Shapes.shapeMedium,
          border: hasGradient
              ? Border.all(color: accentColor.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Padding(
          padding: const M3EdgeInsets.all(M3SpacingToken.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (icon != null)
                    Container(
                      padding: const M3EdgeInsets.all(M3SpacingToken.space8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 18, color: accentColor),
                    ),
                ],
              ),
              SizedBox(height: M3SpacingToken.space8.value),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpressiveSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool hasDivider;

  const ExpressiveSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.hasDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDivider)
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        SizedBox(height: M3SpacingToken.space16.value),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLargeEmphasized?.copyWith(
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: M3SpacingToken.space4.value),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ],
    );
  }
}

class ExpressiveFeedingCard extends StatelessWidget {
  final Widget avatar;
  final String catName;
  final String details;
  final String timeAgo;
  final Color? accentColor;
  final int index;
  final VoidCallback? onTap;

  const ExpressiveFeedingCard({
    super.key,
    required this.avatar,
    required this.catName,
    required this.details,
    required this.timeAgo,
    this.accentColor,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = this.accentColor ?? colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: M3Shapes.shapeMedium,
      child: Container(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: M3Shapes.shapeMedium,
          border: Border.all(color: accentColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            avatar,
            SizedBox(width: M3SpacingToken.space16.value),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    catName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: M3SpacingToken.space4.value),
                  Text(
                    details,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: M3SpacingToken.space4.value),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      SizedBox(width: M3SpacingToken.space4.value),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const M3EdgeInsets.all(M3SpacingToken.space8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pets, size: 16, color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpressiveChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final bool hasData;
  final Color? accentColor;

  const ExpressiveChartContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.chart,
    required this.hasData,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final containerAccentColor = accentColor ?? colorScheme.primary;

    return Container(
      padding: const M3EdgeInsets.all(M3SpacingToken.space16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: M3Shapes.shapeLarge,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLargeEmphasized?.copyWith(
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: M3SpacingToken.space4.value),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const M3EdgeInsets.all(M3SpacingToken.space8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      containerAccentColor.withValues(alpha: 0.2),
                      containerAccentColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: M3Shapes.shapeSmall,
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: containerAccentColor,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          Container(
            constraints: const BoxConstraints(minHeight: 180, maxHeight: 200),
            child: chart,
          ),
        ],
      ),
    );
  }
}

class ExpressiveEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;

  const ExpressiveEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = this.accentColor ?? colorScheme.primary;

    return Container(
      padding: const M3EdgeInsets.all(M3SpacingToken.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: 0.05),
            colorScheme.surfaceContainerLow,
          ],
        ),
        borderRadius: M3Shapes.shapeLarge,
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const M3EdgeInsets.all(M3SpacingToken.space20),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: 0.2),
                  accentColor.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: accentColor),
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: M3SpacingToken.space8.value),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: M3SpacingToken.space20.value),
            FilledButton.tonal(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                padding: const M3EdgeInsets.symmetric(
                  horizontal: M3SpacingToken.space24,
                  vertical: M3SpacingToken.space12,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
