import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/features/notifications/domain/entities/notification.dart'
    as notification_entity;
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

class NotificationsPage extends StatefulWidget {
  /// Callback opcional chamado quando o contador de notificações não lidas muda
  final VoidCallback? onUnreadCountChanged;

  const NotificationsPage({
    super.key,
    this.onUnreadCountChanged,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  List<notification_entity.Notification> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = SupabaseConfig.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _error = 'Usuário não autenticado';
          _isLoading = false;
        });
        return;
      }

      // Buscar notificações do usuário
      final response = await supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final notifications = (response as List<dynamic>)
          .map((json) => _notificationFromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar notificações: $e';
        _isLoading = false;
      });
    }
  }

  notification_entity.Notification _notificationFromJson(
    Map<String, dynamic> json,
  ) {
    // Verificar se está lida: primeiro is_read (boolean), depois read_at (timestamp)
    bool isRead = false;
    if (json['is_read'] != null) {
      isRead = json['is_read'] as bool? ?? false;
    } else if (json['read'] != null) {
      isRead = json['read'] as bool? ?? false;
    } else if (json['read_at'] != null) {
      // Se read_at existe e não é null, foi lida
      isRead = true;
    }
    
    return notification_entity.Notification(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notificação',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      read: isRead,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Future<void> _markAsRead(
    notification_entity.Notification notification,
  ) async {
    if (notification.read) return;

    try {
      final supabase = SupabaseConfig.client;
      
      // Tentar com is_read primeiro, se falhar, tentar read_at (timestamp)
      try {
        await supabase
            .from('notifications')
            .update({'is_read': true})
            .eq('id', notification.id);
      } catch (_) {
        // Se is_read falhar, tentar read_at (timestamp)
        await supabase
            .from('notifications')
            .update({'read_at': DateTime.now().toIso8601String()})
            .eq('id', notification.id);
      }

      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(read: true);
        }
      });

      // Notificar callback para atualizar contador na HomePage
      // Aguardar um pouco para garantir que o banco foi atualizado
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onUnreadCountChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação marcada como lida'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar como lida: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final supabase = SupabaseConfig.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // Tentar com is_read primeiro, se falhar, tentar read_at (timestamp)
      try {
        await supabase
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', user.id)
            .eq('is_read', false);
      } catch (_) {
        // Se is_read falhar, tentar read_at (timestamp)
        // Primeiro buscar todas as notificações não lidas para atualizar
        final unreadNotifications = await supabase
            .from('notifications')
            .select('id')
            .eq('user_id', user.id);
        
        // Filtrar apenas as que não têm read_at
        final notifications = (unreadNotifications as List)
            .where((n) => (n as Map<String, dynamic>)['read_at'] == null)
            .toList();
        
        if (notifications.isNotEmpty) {
          final now = DateTime.now().toIso8601String();
          for (final notification in notifications) {
            await supabase
                .from('notifications')
                .update({'read_at': now})
                .eq('id', (notification as Map<String, dynamic>)['id']);
          }
        }
      }

      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(read: true))
            .toList();
      });

      // Notificar callback para atualizar contador na HomePage
      // Aguardar um pouco para garantir que o banco foi atualizado
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onUnreadCountChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas as notificações foram marcadas como lidas'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar todas como lidas: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(
    notification_entity.Notification notification,
  ) async {
    try {
      final supabase = SupabaseConfig.client;
      await supabase.from('notifications').delete().eq('id', notification.id);

      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });

      // Notificar callback para atualizar contador na HomePage
      // Se a notificação não estava lida, o contador precisa ser atualizado
      if (!notification.read) {
        await Future.delayed(const Duration(milliseconds: 300));
        widget.onUnreadCountChanged?.call();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação removida'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover notificação: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButtonM3E(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma notificação',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Você está em dia!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      );
    }

    final hasUnread = _notifications.any((n) => !n.read);

    return Column(
      children: [
        // Botão "Marcar todas como lidas" fixo no topo
        if (hasUnread)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ElevatedButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Marcar todas como lidas'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        // Lista de notificações
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _NotificationItem(
                  notification: notification,
                  onTap: () => _markAsRead(notification),
                  onDelete: () => _deleteNotification(notification),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final notification_entity.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Agora';
        }
        return '${difference.inMinutes} min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'error':
        return Icons.error_outline;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(BuildContext context, String type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return colorScheme.error;
      case 'info':
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.read;
    final date = notification.createdAt ?? DateTime.now();

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForType(context, notification.type)
              .withValues(alpha: 0.1),
          child: Icon(
            _getIconForType(notification.type),
            color: _getColorForType(context, notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de não lida
            if (isUnread)
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            // Botão de deletar
            IconButtonM3E(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              onPressed: onDelete,
              tooltip: 'Deletar notificação',
            ),
          ],
        ),
        onTap: onTap,
        selected: isUnread,
      ),
    );
  }
}

