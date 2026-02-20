import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design/material_design.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';

/// Altura fixa da área de imagem do card (squircle proeminente).
const double _kCatCardImageSize = 140.0;

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
          borderRadius: M3Shapes.shapeExpressiveLarge,
          child: Container(
            height: _kCatCardImageSize + (M3SpacingToken.space16.value * 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surfaceContainerLow,
                  colorScheme.surfaceContainerLow
                      .withValues(alpha: 0.9),
                ],
              ),
              borderRadius: M3Shapes.shapeExpressiveLarge,
              border: Border.all(
                color: genderColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const M3EdgeInsets.all(M3SpacingToken.space16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: _kCatCardImageSize,
                        height: _kCatCardImageSize,
                        child: _buildCatImage(context, genderColor),
                      ),
                      SizedBox(width: M3SpacingToken.space16.value),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: M3SpacingToken.space32.value,
                          ),
                          child: _buildCatInfo(context, genderColor),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: _buildActionButtons(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatImage(BuildContext context, Color genderColor) {
    final imageUrl = widget.cat.imageUrl;
    final hasValidImageUrl =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    Widget imageContent;

    if (hasValidImageUrl) {
      imageContent = CachedNetworkImage(
        imageUrl: imageUrl.trim(),
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: _kCatCardImageSize,
          height: _kCatCardImageSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                genderColor.withValues(alpha: 0.12),
                genderColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Center(
            child: Material3LoadingIndicator(size: 32.0),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderImage(
          genderColor,
        ),
      );
    } else {
      imageContent = _buildPlaceholderImage(genderColor);
    }

    return Hero(
      tag: 'cat_avatar_${widget.cat.id}',
      child: ClipPath(
        clipper: _SquircleClipper(),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: genderColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: imageContent,
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(Color genderColor) {
    return Container(
      width: _kCatCardImageSize,
      height: _kCatCardImageSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            genderColor.withValues(alpha: 0.2),
            genderColor.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Icon(Icons.pets, size: 48, color: genderColor),
    );
  }

  Widget _buildCatInfo(BuildContext context, Color genderColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.cat.name,
              style: (theme.textTheme.titleLargeEmphasized ??
                  theme.textTheme.titleLarge)?.copyWith(
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.cat.breed != null) ...[
              SizedBox(height: M3SpacingToken.space4.value),
              Text(
                widget.cat.breed!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  widget.cat.gender == 'M'
                      ? Icons.male
                      : Icons.female,
                  size: 14,
                  color: genderColor,
                ),
                SizedBox(width: M3SpacingToken.space4.value),
                Flexible(
                  child: Text(
                    widget.cat.gender == 'M'
                        ? context.l10n.cats_genderMale
                        : context.l10n.cats_genderFemale,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: genderColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: M3SpacingToken.space4.value),
            Row(
              children: [
                Icon(
                  Icons.cake,
                  size: 14,
                  color: colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
                SizedBox(width: M3SpacingToken.space4.value),
                Flexible(
                  child: Text(
                    widget.cat.ageDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (widget.cat.currentWeight != null) ...[
              SizedBox(height: M3SpacingToken.space4.value),
              Row(
                children: [
                  Icon(
                    Icons.monitor_weight,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: M3SpacingToken.space4.value),
                  Flexible(
                    child: Text(
                      context.l10n.home_cat_weight(
                        NumberFormat(
                          '0.0',
                          Localizations.localeOf(context).toString(),
                        ).format(widget.cat.currentWeight!),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
              Text(
                context.l10n.common_delete,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ],
      child: Semantics(
        label: 'More options',
        button: true,
        child: Material(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: null,
            child: Padding(
              padding: const M3EdgeInsets.all(M3SpacingToken.space8),
              child: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clipper que desenha um squircle usando o shape M3 Expressive.
class _SquircleClipper extends CustomClipper<Path> {
  _SquircleClipper();

  @override
  Path getClip(Size size) {
    return M3Shapes.squircleLarge.getOuterPath(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
