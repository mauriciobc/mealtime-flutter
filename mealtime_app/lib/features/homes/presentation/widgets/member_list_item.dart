import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
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
    final name =
        member.user.fullName.isEmpty ? 'Sem nome' : member.user.fullName;
    final showActions =
        !isCurrentUser && !isAdmin && (onPromote != null || onRemove != null);

    return M3EListItem(
      headline: name,
      supportingText: member.user.email,
      overline: isAdmin ? 'Administrador' : 'Membro',
      leading: _buildAvatar(context),
      trailing: showActions
          ? PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
                        const Icon(Icons.admin_panel_settings),
                        SizedBox(width: M3SpacingToken.space8.value),
                        const Text('Promover a Admin'),
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
            )
          : null,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final name = member.user.fullName.isEmpty
        ? member.user.email
        : member.user.fullName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
