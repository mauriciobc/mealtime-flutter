import 'package:flutter/material.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';

/// Identificadores de tipo de comida, independentes de idioma.
/// A camada de apresentação usa [localizedFoodType] para obter o texto traduzido.
abstract final class FoodTypeIds {
  FoodTypeIds._();

  static const String dryFood = 'dry_food';
  static const String wetFood = 'wet_food';
  static const String homemadeFood = 'homemade_food';
  static const String sachet = 'sachet';
  static const String treat = 'treat';

  /// Lista de ids usada no formulário (dropdown).
  static const List<String> all = [
    dryFood,
    wetFood,
    sachet,
    treat,
  ];
}

/// Converte valor legado (ex: 'Ração Seca') ou id para o id canônico.
/// Usado no formulário para que o dropdown mostre a opção certa quando
/// o dado veio do banco com texto em português.
String? normalizeToFoodTypeId(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  switch (value) {
    case FoodTypeIds.dryFood:
    case 'Ração Seca':
      return FoodTypeIds.dryFood;
    case FoodTypeIds.wetFood:
    case 'Ração Úmida':
      return FoodTypeIds.wetFood;
    case FoodTypeIds.homemadeFood:
    case 'Comida Caseira':
      return FoodTypeIds.homemadeFood;
    case FoodTypeIds.sachet:
    case 'Sachê':
      return FoodTypeIds.sachet;
    case FoodTypeIds.treat:
    case 'Petisco':
      return FoodTypeIds.treat;
    default:
      return value;
  }
}

/// Retorna o rótulo localizado para [foodTypeId].
/// Aceita tanto os novos ids (dry_food, etc.) quanto valores antigos em
/// português para compatibilidade com dados já persistidos.
String? localizedFoodType(BuildContext context, String? foodTypeId) {
  if (foodTypeId == null || foodTypeId.trim().isEmpty) return null;
  final l10n = context.l10n;
  switch (foodTypeId) {
    case FoodTypeIds.dryFood:
    case 'Ração Seca':
      return l10n.home_food_dry;
    case FoodTypeIds.wetFood:
    case 'Ração Úmida':
      return l10n.home_food_wet;
    case FoodTypeIds.homemadeFood:
    case 'Comida Caseira':
      return l10n.home_food_homemade;
    case FoodTypeIds.sachet:
    case 'Sachê':
      return l10n.home_food_sachet;
    case FoodTypeIds.treat:
    case 'Petisco':
      return l10n.home_food_treat;
    default:
      return foodTypeId;
  }
}
