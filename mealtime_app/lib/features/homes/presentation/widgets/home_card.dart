import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';

class HomeCard extends StatelessWidget {
  final Home home;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetActive;
  final int? membersCount;

  const HomeCard({
    super.key,
    required this.home,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetActive,
    this.membersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: M3Shapes.shapeMedium,
        child: Padding(
          padding: const M3EdgeInsets.all(M3SpacingToken.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const M3EdgeInsets.all(M3SpacingToken.space8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: M3Shapes.shapeSmall,
                    ),
                    child: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: M3SpacingToken.space12.value),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          home.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (home.address != null) ...[
                          SizedBox(height: M3SpacingToken.space4.value),
                          Text(
                            home.address!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (home.isActive)
                    Container(
                      padding: const M3EdgeInsets.symmetric(
                        horizontal: M3SpacingToken.space8,
                        vertical: M3SpacingToken.space4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: M3Shapes.shapeMedium,
                      ),
                      child: Text(
                        'ATIVA',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (home.description != null) ...[
                SizedBox(height: M3SpacingToken.space12.value),
                Text(
                  home.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: M3SpacingToken.space12.value),
              // Contador de membros
              if (membersCount != null)
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: M3SpacingToken.space4.value),
                    Text(
                      '$membersCount Membro${membersCount != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              if (membersCount != null) SizedBox(height: M3SpacingToken.space12.value),
              Row(
                children: [
                  Text(
                    'Criada em ${_formatDate(home.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    IconButtonM3E(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Editar',
                    ),
                  if (onSetActive != null && !home.isActive)
                    IconButtonM3E(
                      onPressed: onSetActive,
                      icon: const Icon(Icons.home, size: 20),
                      tooltip: 'Definir como Ativa',
                    ),
                  if (onDelete != null)
                    IconButtonM3E(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      tooltip: 'Excluir',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
