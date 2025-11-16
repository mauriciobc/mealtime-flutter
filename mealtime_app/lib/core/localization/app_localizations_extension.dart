import 'package:flutter/material.dart';
import 'package:mealtime_app/l10n/app_localizations.dart';

/// Extensão para facilitar o acesso às traduções
extension AppLocalizationsExtension on BuildContext {
  /// Acessa as traduções através de context.l10n
  /// 
  /// Exemplo de uso:
  /// ```dart
  /// Text(context.l10n.profile)
  /// ```
  AppLocalizations get l10n => AppLocalizations.of(this);
}

