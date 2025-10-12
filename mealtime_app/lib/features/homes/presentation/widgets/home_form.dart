import 'package:flutter/material.dart';

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
          decoration: const InputDecoration(
            labelText: 'Nome da Residência *',
            hintText: 'Ex: Casa Principal, Apartamento, Sítio...',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'O nome da residência é obrigatório';
            }
            if (value.trim().length < 2) {
              return 'O nome deve ter pelo menos 2 caracteres';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            hintText: 'Informações adicionais sobre a residência...',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Text(
          '* Campos obrigatórios',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
