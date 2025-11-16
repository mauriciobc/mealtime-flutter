import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';

/// Widget para exibir um item de membro na lista de membros do household
class MemberListItem extends StatelessWidget {
  final HouseholdMemberDetailed member;
  final bool isCurrentUser;
  final VoidCallback? onPromote;
  final VoidCallback? onRemove;

  const MemberListItem({
    super.key,
    required this.member,
    this.isCurrentUser = false,
    this.onPromote,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = member.role == 'ADMIN';

    return Card(
      margin: EdgeInsets.only(bottom: M3SpacingToken.space8.value),
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Row(
          children: [
            // Avatar com inicial do nome
            _buildAvatar(context),
            SizedBox(width: M3SpacingToken.space16.value),
            
            // Nome e email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.user.fullName.isEmpty 
                      ? 'Sem nome' 
                      : member.user.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: M3SpacingToken.space4.value),
                  Text(
                    member.user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: M3SpacingToken.space12.value),
            
            // Badge de role
            _buildRoleBadge(context, isAdmin),
            
            // Menu de ações (apenas para não-admins e não-current-user)
            if (!isCurrentUser && !isAdmin && (onPromote != null || onRemove != null))
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Ações para ${member.user.fullName}',
                onSelected: (value) {
                  if (value == 'promote' && onPromote != null) {
                    onPromote!();
                  } else if (value == 'remove' && onRemove != null) {
                    onRemove!();
                  }
                },
                itemBuilder: (context) => [
                  if (onPromote != null)
                    PopupMenuItem(
                      value: 'promote',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings),
                          SizedBox(width: M3SpacingToken.space8.value),
                          Text('Promover a Admin'),
                        ],
                      ),
                    ),
                  if (onRemove != null)
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_remove,
                            color: theme.colorScheme.error,
                          ),
                          SizedBox(width: M3SpacingToken.space8.value),
                          Text(
                            'Remover',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final name = member.user.fullName.isEmpty 
      ? member.user.email 
      : member.user.fullName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initial,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, bool isAdmin) {
    final theme = Theme.of(context);
    
    if (isAdmin) {
      return Container(
        padding: const M3EdgeInsets.symmetric(
          horizontal: M3SpacingToken.space12,
          vertical: M3SpacingToken.space8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: M3Shapes.shapeLarge,
        ),
        child: Text(
          'Administrador',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Container(
        padding: const M3EdgeInsets.symmetric(
          horizontal: M3SpacingToken.space12,
          vertical: M3SpacingToken.space8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: M3Shapes.shapeLarge,
        ),
        child: Text(
          'Membro',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }
}







