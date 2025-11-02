import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

/// Widget de card de gato para exibir no grid de gatos do household
class HouseholdCatCard extends StatelessWidget {
  final Cat cat;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? lastFeedingStatus;

  const HouseholdCatCard({
    super.key,
    required this.cat,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.lastFeedingStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do gato
            _buildCatImage(context),
            
            // Informações do gato
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  Text(
                    cat.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Informações (idade e peso)
                  _buildInfoChips(context),
                  
                  const SizedBox(height: 8),
                  
                  // Status de alimentação
                  Text(
                    lastFeedingStatus ?? 'Nunca alimentado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Botões de ação
            Padding(
              padding: const EdgeInsets.only(
                left: 4,
                right: 4,
                bottom: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      iconSize: 20,
                      tooltip: 'Editar ${cat.name}',
                      color: theme.colorScheme.primary,
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      iconSize: 20,
                      tooltip: 'Excluir ${cat.name}',
                      color: theme.colorScheme.error,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatImage(BuildContext context) {
    final theme = Theme.of(context);
    
    // Validar se a URL existe e é válida (começa com http)
    final imageUrl = cat.imageUrl;
    final trimmedUrl = imageUrl?.trim();
    
    if (trimmedUrl != null && 
        trimmedUrl.isNotEmpty &&
        (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://'))) {
      return AspectRatio(
        aspectRatio: 1,
        child: CachedNetworkImage(
          imageUrl: trimmedUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Material3LoadingIndicator(size: 24.0),
            ),
          ),
          errorWidget: (context, url, error) {
            // Log para debug (pode remover depois)
            debugPrint('Erro ao carregar imagem do gato: $url - Erro: $error');
            return _buildPlaceholder(context);
          },
        ),
      );
    }
    
    return AspectRatio(
      aspectRatio: 1,
      child: _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.pets,
        size: 64,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildInfoChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Idade
        _buildInfoChip(
          context,
          Icons.cake,
          cat.ageDescription,
        ),
        
        // Peso
        if (cat.currentWeight != null)
          _buildInfoChip(
            context,
            Icons.monitor_weight,
            '${cat.currentWeight!.toStringAsFixed(cat.currentWeight! % 1 == 0 ? 0 : 1)} kg',
          ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

