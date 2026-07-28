import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:material_3_expressive/components/buttons/styles/m3e_button_decoration.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:mealtime_app/core/theme/contrast_utils.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';

/// Façade estável sobre [M3EBottomSheet].
///
/// Preserva a API pública usada pelos call sites (`title`, `leading`,
/// `height`, etc.) enquanto delega a apresentação ao pacote
/// `material_3_expressive`.
class ExpressiveBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? leading;
  final bool showDragHandle;
  final bool isDismissible;
  /// When false, child is not wrapped in SingleChildScrollView (for content
  /// with its own scroll e.g. ListView).
  final bool scrollable;

  const ExpressiveBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.showDragHandle = true,
    this.isDismissible = true,
    this.scrollable = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? leading,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool scrollable = true,
    bool isScrollControlled = false,
    /// Fixed height; sheet is exactly this tall.
    double? height,
    /// Max height; sheet sizes to content but never taller than this.
    double? maxHeight,
  }) {
    // API mismatch: M3EBottomSheet.show always uses barrierDismissible: true
    // and has no isScrollControlled flag. [isDismissible] /
    // [isScrollControlled] are kept for call-site compatibility only.
    HapticsService.mediumImpact();
    return M3EBottomSheet.show<T>(
      context,
      showDragHandle: showDragHandle,
      builder: (sheetContext) {
        Widget content = ExpressiveBottomSheet(
          title: title,
          leading: leading,
          showDragHandle: false,
          isDismissible: isDismissible,
          scrollable: scrollable,
          child: child,
        );
        if (height != null) {
          content = SizedBox(height: height, child: content);
        } else if (maxHeight != null) {
          content = ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: content,
          );
        }
        return content;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // M3EBottomSheet does not provide a Material ancestor. Material widgets
    // inside the sheet (TextButton, InkWell, Checkbox, etc.) require one.
    return Material(
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || leading != null)
            Padding(
              padding: const M3EdgeInsets.symmetric(
                horizontal: M3SpacingToken.space16,
                vertical: M3SpacingToken.space16,
              ),
              child: Row(
                children: [
                  if (leading != null) leading!,
                  if (leading != null)
                    SizedBox(width: M3SpacingToken.space12.value),
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.noScaling,
                      ),
                    ),
                ],
              ),
            ),
          if (scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const M3EdgeInsets.all(M3SpacingToken.space16),
                child: child,
              ),
            )
          else
            Flexible(
              child: Padding(
                padding: const M3EdgeInsets.all(M3SpacingToken.space16),
                child: child,
              ),
            ),
        ],
      ),
    );
  }
}

/// Façade estável sobre [M3EDialog].
class ExpressiveDialog extends StatelessWidget {
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
    return M3EDialog.show<T>(
      context,
      barrierDismissible: isDismissible,
      dialog: ExpressiveDialog(
        icon: icon,
        title: title,
        content: content,
        actions: actions,
        isDismissible: isDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return M3EDialog(
      icon: icon,
      title: title,
      content: content != null ? Text(content!) : null,
      actions: actions,
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
  final colorScheme = Theme.of(context).colorScheme;

  HapticsService.mediumImpact();

  final Color resolvedConfirm =
      confirmColor ??
      (isDestructive ? colorScheme.error : colorScheme.primary);
  final Color resolvedOnConfirm = confirmColor != null
      ? ContrastUtils.getContrastText(
          confirmColor,
          minRatio: ContrastUtils.wcagAANormalText,
        )
      : (isDestructive ? colorScheme.onError : colorScheme.onPrimary);

  return M3EDialog.show<void>(
    context,
    dialog: M3EDialog(
      icon: Icon(
        isDestructive ? Icons.warning_amber : Icons.help_outline,
        color: isDestructive ? colorScheme.error : colorScheme.primary,
      ),
      title: title,
      content: Text(message),
      actions: [
        M3EButton(
          style: M3EButtonStyle.text,
          onPressed: () {
            HapticsService.lightImpact();
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        M3EButton(
          onPressed: () {
            HapticsService.heavyImpact();
            Navigator.of(context).pop();
            onConfirm();
          },
          decoration: M3EButtonDecoration.styleFrom(
            backgroundColor: resolvedConfirm,
            foregroundColor: resolvedOnConfirm,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
