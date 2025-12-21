import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/shared/widgets/bouncing_widget.dart';

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
    return BouncingWidget(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: M3Shapes.shapeLarge,
          child: Padding(
            padding: const M3EdgeInsets.all(M3SpacingToken.space16),
            child: Row(
              children: [
                _buildCatAvatar(context),
                SizedBox(width: M3SpacingToken.space16.value),
                Expanded(child: _buildCatInfo(context)),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatAvatar(BuildContext context) {
    final theme = Theme.of(context);
    
    // Validar se a URL existe e é válida (começa com http)
    final imageUrl = cat.imageUrl;
    final hasValidImageUrl = imageUrl != null && 
        imageUrl.isNotEmpty && 
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    
    Widget avatarContent;
    
    if (hasValidImageUrl) {
      final trimmedUrl = imageUrl.trim();
      
      avatarContent = SizedBox(
        width: 60,
        height: 60,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: trimmedUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 60,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Material3LoadingIndicator(size: 24.0),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                width: 60,
                height: 60,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.pets,
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),
        ),
      );
    } else {
      avatarContent = CircleAvatar(
        radius: 30,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.pets,
          size: 30,
          color: theme.colorScheme.primary,
        ),
      );
    }

    // Wrap with Hero for seamless transition
    return Hero(
      tag: 'cat_avatar_${cat.id}',
      child: avatarContent,
    );
  }

  Widget _buildCatInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cat.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: M3SpacingToken.space4.value),
        if (cat.breed != null) ...[
          Text(
            cat.breed!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: M3SpacingToken.space4.value),
        ],
        Row(
          children: [
            Icon(
              Icons.cake,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(width: M3SpacingToken.space4.value),
            Text(
              cat.ageDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (cat.gender != null) ...[
              SizedBox(width: M3SpacingToken.space16.value),
              Icon(
                cat.gender == 'M' ? Icons.male : Icons.female,
                size: 16,
                color: cat.gender == 'M' 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
              ),
              SizedBox(width: M3SpacingToken.space4.value),
              Text(
                cat.gender == 'M' ? 'Macho' : 'Fêmea',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
        if (cat.currentWeight != null) ...[
          SizedBox(height: M3SpacingToken.space4.value),
          Row(
            children: [
              Icon(
                Icons.monitor_weight,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(width: M3SpacingToken.space4.value),
              Text(
                '${cat.currentWeight!.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
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
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
              SizedBox(width: M3SpacingToken.space8.value),
              const Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              SizedBox(width: M3SpacingToken.space8.value),
              Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
      ],
      child: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}
