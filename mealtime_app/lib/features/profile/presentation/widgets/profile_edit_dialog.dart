import 'package:flutter/material.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/utils/timezone_helper.dart';

class ProfileEditDialog extends StatefulWidget {
  final Profile profile;

  const ProfileEditDialog({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
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
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar Perfil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
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
                  ),
                  textCapitalization: TextCapitalization.none,
                );
              },
              onSelected: (String selection) {
                setState(() {
                  _currentTimezone = selection;
                });
              },
              displayStringForOption: (String option) => option,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

