import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';

class ExpressiveCatCard extends StatefulWidget {
  final Cat cat;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpressiveCatCard({
    super.key,
    required this.cat,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ExpressiveCatCard> createState() => _ExpressiveCatCardState();
}

class _ExpressiveCatCardState extends State<ExpressiveCatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3Animation.durationLong1,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGenderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return widget.cat.gender == 'M'
        ? colorScheme.primary
        : colorScheme.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final genderColor = _getGenderColor(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(scale: _scaleAnimation, child: child),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: M3Shapes.shapeLarge,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surfaceContainer,
                  colorScheme.surfaceContainer.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: M3Shapes.shapeLarge,
              border: Border.all(color: genderColor.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const M3EdgeInsets.all(M3SpacingToken.space16),
              child: Row(
                children: [
                  _buildCatAvatar(context, genderColor),
                  SizedBox(width: M3SpacingToken.space16.value),
                  Expanded(child: _buildCatInfo(context, genderColor)),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatAvatar(BuildContext context, Color genderColor) {
    final imageUrl = widget.cat.imageUrl;
    final hasValidImageUrl =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    Widget avatarContent;

    if (hasValidImageUrl) {
      avatarContent = SizedBox(
        width: 64,
        height: 64,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl.trim(),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    genderColor.withValues(alpha: 0.1),
                    genderColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: const Center(child: Material3LoadingIndicator(size: 24.0)),
            ),
            errorWidget: (context, url, error) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      genderColor.withValues(alpha: 0.2),
                      genderColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(Icons.pets, size: 32, color: genderColor),
              );
            },
          ),
        ),
      );
    } else {
      avatarContent = Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              genderColor.withValues(alpha: 0.2),
              genderColor.withValues(alpha: 0.1),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.pets, size: 32, color: genderColor),
      );
    }

    return Hero(
      tag: 'cat_avatar_${widget.cat.id}',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: genderColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: avatarContent,
      ),
    );
  }

  Widget _buildCatInfo(BuildContext context, Color genderColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.cat.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: M3SpacingToken.space4.value),
        if (widget.cat.breed != null)
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              SizedBox(width: M3SpacingToken.space4.value),
              Expanded(
                child: Text(
                  widget.cat.breed!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        SizedBox(height: M3SpacingToken.space4.value),
        Row(
          children: [
            Container(
              padding: const M3EdgeInsets.symmetric(
                horizontal: M3SpacingToken.space8,
                vertical: M3SpacingToken.space4,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    genderColor.withValues(alpha: 0.15),
                    genderColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: M3Shapes.shapeSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.cat.gender == 'M' ? Icons.male : Icons.female,
                    size: 14,
                    color: genderColor,
                  ),
                  SizedBox(width: M3SpacingToken.space4.value),
                  Text(
                    widget.cat.gender == 'M' ? context.l10n.cats_genderMale : context.l10n.cats_genderFemale,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: genderColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: M3SpacingToken.space12.value),
            Row(
              children: [
                Icon(
                  Icons.cake,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                SizedBox(width: M3SpacingToken.space4.value),
                Text(
                  widget.cat.ageDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (widget.cat.currentWeight != null) ...[
          SizedBox(height: M3SpacingToken.space8.value),
          Row(
            children: [
              Container(
                padding: const M3EdgeInsets.all(M3SpacingToken.space4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.monitor_weight,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: M3SpacingToken.space8.value),
              Text(
                '${widget.cat.currentWeight!.toStringAsFixed(1)} kg',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: colorScheme.onSurface),
              SizedBox(width: M3SpacingToken.space8.value),
              Text(context.l10n.common_edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: colorScheme.error),
              SizedBox(width: M3SpacingToken.space8.value),
              Text(context.l10n.common_delete, style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const M3EdgeInsets.all(M3SpacingToken.space8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
