import 'package:flutter/material.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

class CatCard extends StatelessWidget {
  final Cat cat;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CatCard({
    super.key,
    required this.cat,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildCatAvatar(context),
              const SizedBox(width: 16),
              Expanded(child: _buildCatInfo(context)),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      backgroundImage: cat.imageUrl != null
          ? NetworkImage(cat.imageUrl!)
          : null,
      child: cat.imageUrl == null
          ? Icon(
              Icons.pets,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildCatInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cat.name,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        if (cat.breed != null) ...[
          Text(
            cat.breed!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Icon(
              Icons.cake,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              cat.ageDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (cat.gender != null) ...[
              const SizedBox(width: 16),
              Icon(
                cat.gender == 'M' ? Icons.male : Icons.female,
                size: 16,
                color: cat.gender == 'M' ? Colors.blue : Colors.pink,
              ),
              const SizedBox(width: 4),
              Text(
                cat.gender == 'M' ? 'Macho' : 'Fêmea',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
        if (cat.currentWeight != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.monitor_weight,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${cat.currentWeight!.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [Icon(Icons.edit), SizedBox(width: 8), Text('Editar')],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}
