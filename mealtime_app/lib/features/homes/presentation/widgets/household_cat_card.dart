import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:m3e_collection/m3e_collection.dart';

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
              padding: const M3EdgeInsets.all(M3SpacingToken.space12),
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
                  SizedBox(height: M3SpacingToken.space8.value),
                  
                  // Informações (idade e peso)
                  _buildInfoChips(context),
                  
                  SizedBox(height: M3SpacingToken.space8.value),
                  
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
              padding: const M3EdgeInsets.only(
                left: M3SpacingToken.space4,
                right: M3SpacingToken.space4,
                bottom: M3SpacingToken.space4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    IconButtonM3E(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: 'Editar ${cat.name}',
                    ),
                  if (onDelete != null)
                    IconButtonM3E(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Excluir ${cat.name}',
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
        SizedBox(width: M3SpacingToken.space4.value),
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

