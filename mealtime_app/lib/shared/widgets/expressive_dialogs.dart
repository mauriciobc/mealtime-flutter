import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';

class ExpressiveBottomSheet extends StatefulWidget {
  final Widget child;
  final String? title;
  final Widget? leading;
  final bool showDragHandle;
  final bool isDismissible;

  const ExpressiveBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.showDragHandle = true,
    this.isDismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? leading,
    bool showDragHandle = true,
    bool isDismissible = true,
  }) {
    HapticsService.mediumImpact();
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: false,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpressiveBottomSheet(
        title: title,
        leading: leading,
        showDragHandle: showDragHandle,
        isDismissible: isDismissible,
        child: child,
      ),
    );
  }

  @override
  State<ExpressiveBottomSheet> createState() => _ExpressiveBottomSheetState();
}

class _ExpressiveBottomSheetState extends State<ExpressiveBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3Animation.durationMedium1,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onVerticalDragStart: (_) {
        HapticsService.lightImpact();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(scale: _scaleAnimation, child: child),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surfaceContainerHigh,
                colorScheme.surfaceContainer,
              ],
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(M3Shapes.shapeLarge.topLeft.x),
            ),
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDragHandle)
                Container(
                  margin: const M3EdgeInsets.only(top: M3SpacingToken.space8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              if (widget.title != null || widget.leading != null)
                Padding(
                  padding: const M3EdgeInsets.symmetric(
                    horizontal: M3SpacingToken.space16,
                    vertical: M3SpacingToken.space16,
                  ),
                  child: Row(
                    children: [
                      if (widget.leading != null) widget.leading!,
                      if (widget.leading != null)
                        SizedBox(width: M3SpacingToken.space12.value),
                      if (widget.title != null)
                        Expanded(
                          child: Text(
                            widget.title!,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const M3EdgeInsets.all(M3SpacingToken.space16),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpressiveDialog extends StatefulWidget {
  final Widget icon;
  final String title;
  final String? content;
  final List<Widget> actions;
  final bool isDismissible;

  const ExpressiveDialog({
    super.key,
    required this.icon,
    required this.title,
    this.content,
    this.actions = const [],
    this.isDismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget icon,
    required String title,
    String? content,
    List<Widget> actions = const [],
    bool isDismissible = true,
  }) {
    HapticsService.mediumImpact();
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: M3Animation.durationMedium1,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return ExpressiveDialog(
          icon: icon,
          title: title,
          content: content,
          actions: actions,
          isDismissible: isDismissible,
        );
      },
    );
  }

  @override
  State<ExpressiveDialog> createState() => _ExpressiveDialogState();
}

class _ExpressiveDialogState extends State<ExpressiveDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: M3Shapes.shapeLarge,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      icon: Container(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.8),
              colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: widget.icon,
      ),
      title: Text(
        widget.title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      content: widget.content != null
          ? Text(
              widget.content!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            )
          : null,
      actions: widget.actions.isNotEmpty
          ? [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.actions.map((action) {
                  return Expanded(
                    child: Padding(
                      padding: const M3EdgeInsets.symmetric(
                        horizontal: M3SpacingToken.space8,
                      ),
                      child: action,
                    ),
                  );
                }).toList(),
              ),
            ]
          : null,
      actionsPadding: const M3EdgeInsets.all(M3SpacingToken.space16),
    );
  }
}

Future<void> showExpressiveConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  Color? confirmColor,
  bool isDestructive = false,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  HapticsService.mediumImpact();

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: M3Animation.durationMedium1,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: M3Shapes.shapeLarge,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        icon: Container(
          padding: const M3EdgeInsets.all(M3SpacingToken.space16),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.8),
                colorScheme.primary.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDestructive ? Icons.warning_amber : Icons.help_outline,
            size: 32,
            color: isDestructive ? colorScheme.error : colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const M3EdgeInsets.symmetric(
                    horizontal: M3SpacingToken.space8,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      HapticsService.lightImpact();
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                    child: Text(cancelText),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const M3EdgeInsets.symmetric(
                    horizontal: M3SpacingToken.space8,
                  ),
                  child: FilledButton(
                    onPressed: () {
                      HapticsService.heavyImpact();
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          confirmColor ??
                          (isDestructive
                              ? colorScheme.error
                              : colorScheme.primary),
                    ),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        color: confirmColor != null
                            ? (confirmColor!.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white)
                            : (isDestructive
                                  ? colorScheme.onError
                                  : colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const M3EdgeInsets.all(M3SpacingToken.space16),
      );
    },
  );
}
