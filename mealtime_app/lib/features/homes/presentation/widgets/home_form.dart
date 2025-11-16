import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';

class HomeForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const HomeForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: context.l10n.homes_nameRequired,
            hintText: context.l10n.homes_nameHint,
            prefixIcon: const Icon(Icons.home),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.homes_nameRequiredError;
            }
            if (value.trim().length < 2) {
              return context.l10n.homes_nameMinLength;
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: M3SpacingToken.space16.value),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: context.l10n.common_description,
            hintText: context.l10n.homes_descriptionHint,
            prefixIcon: const Icon(Icons.description),
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          maxLines: 3,
        ),
        SizedBox(height: M3SpacingToken.space16.value),
        Text(
          context.l10n.homes_requiredFields,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
