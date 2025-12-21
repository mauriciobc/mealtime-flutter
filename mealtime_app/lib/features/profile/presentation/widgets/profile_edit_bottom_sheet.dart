import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/utils/timezone_helper.dart';

class ProfileEditBottomSheet extends StatefulWidget {
  final Profile profile;

  const ProfileEditBottomSheet({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileEditBottomSheet> createState() => _ProfileEditBottomSheetState();
}

class _ProfileEditBottomSheetState extends State<ProfileEditBottomSheet> {
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  String _currentTimezone = '';
  TextEditingController? _autocompleteController;
  VoidCallback? _autocompleteListener;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _currentTimezone = widget.profile.timezone ?? '';
  }

  @override
  void dispose() {
    // Remover listener do controller do Autocomplete se existir
    if (_autocompleteController != null && _autocompleteListener != null) {
      _autocompleteController!.removeListener(_autocompleteListener!);
    }
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: M3SpacingToken.space24.value,
        right: M3SpacingToken.space24.value,
        top: M3SpacingToken.space24.value,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar Perfil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.none,
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _currentTimezone),
              optionsBuilder: (textEditingValue) {
                final query = textEditingValue.text.trim();
                if (query.isEmpty) {
                  return TimezoneHelper.commonTimezones;
                }
                return TimezoneHelper.searchTimezones(query);
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                // Armazenar referência ao controller e adicionar listener apenas uma vez
                if (_autocompleteController != textEditingController) {
                  // Remover listener anterior se existir
                  if (_autocompleteController != null && 
                      _autocompleteListener != null) {
                    _autocompleteController!.removeListener(_autocompleteListener!);
                  }
                  
                  _autocompleteController = textEditingController;
                  
                  // Criar e adicionar novo listener
                  _autocompleteListener = () {
                    final newValue = textEditingController.text;
                    if (_currentTimezone != newValue) {
                      setState(() {
                        _currentTimezone = newValue;
                      });
                    }
                  };
                  
                  textEditingController.addListener(_autocompleteListener!);
                }

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (value) => onFieldSubmitted(),
                  decoration: const InputDecoration(
                    labelText: 'Fuso horário',
                    prefixIcon: Icon(Icons.access_time),
                    hintText: 'Digite para buscar (ex: America/Sao_Paulo)',
                    helperText: 'Use o formato IANA (ex: America/Sao_Paulo)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.none,
                );
              },
              onSelected: (String selection) {
                HapticsService.selectionClick();
                setState(() {
                  _currentTimezone = selection;
                });
              },
              displayStringForOption: (String option) => option,
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                SizedBox(width: M3SpacingToken.space16.value),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
            SizedBox(height: M3SpacingToken.space24.value),
          ],
        ),
      ),
    );
  }

  void _save() {
    HapticsService.lightImpact();
    // Trim e atribuir variáveis locais
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final timezone = _currentTimezone.trim();

    // Validar username
    if (username.isEmpty) {
      _showError('Username é obrigatório');
      return;
    }

    if (username.length < 3) {
      _showError('Username deve ter pelo menos 3 caracteres');
      return;
    }

    if (username.length > 30) {
      _showError('Username deve ter no máximo 30 caracteres');
      return;
    }

    // Validar caracteres permitidos para username (alfanumérico e underscore)
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      _showError(
        'Username pode conter apenas letras, números e underscore',
      );
      return;
    }

    // Validar timezone se fornecido
    if (timezone.isNotEmpty) {
      if (!TimezoneHelper.isValidTimezone(timezone)) {
        _showError(
          'Timezone inválido. Use um identificador IANA válido '
          '(ex: America/Sao_Paulo)',
        );
        return;
      }
    }

    // Se todas as validações passaram, criar o perfil atualizado
    final updatedProfile = widget.profile.copyWith(
      username: username,
      fullName: fullName.isEmpty ? null : fullName,
      timezone: timezone.isEmpty ? null : timezone,
    );

    Navigator.of(context).pop(updatedProfile);
  }

  void _showError(String message) {
    HapticsService.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: M3Shapes.shapeMedium,
        ),
      ),
    );
  }
}

