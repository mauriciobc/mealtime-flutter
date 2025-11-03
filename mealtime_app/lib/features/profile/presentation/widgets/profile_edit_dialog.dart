import 'package:flutter/material.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';

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
  late TextEditingController _timezoneController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _timezoneController = TextEditingController(text: widget.profile.timezone);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _timezoneController.dispose();
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
            TextField(
              controller: _timezoneController,
              decoration: const InputDecoration(
                labelText: 'Fuso horário',
                prefixIcon: Icon(Icons.access_time),
                hintText: 'Ex: America/Sao_Paulo',
              ),
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
    final updatedProfile = widget.profile.copyWith(
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      fullName: _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim(),
      timezone: _timezoneController.text.trim().isEmpty
          ? null
          : _timezoneController.text.trim(),
    );

    Navigator.of(context).pop(updatedProfile);
  }
}

