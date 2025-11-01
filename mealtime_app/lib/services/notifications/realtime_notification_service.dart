import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:mealtime_app/services/notifications/notification_service.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';

/// Serviço para escutar notificações em tempo real do Supabase
/// Integra REALTIME subscriptions com o sistema de notificações locais
class RealtimeNotificationService {
  RealtimeChannel? _notificationsChannel;
  RealtimeChannel? _scheduledChannel;
  final NotificationService _localNotificationService;

  RealtimeNotificationService(this._localNotificationService);

  /// Inicializa as subscriptions REALTIME para notificações
  Future<void> initialize() async {
    final supabase = SupabaseConfig.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('[RealtimeNotificationService] Usuário não autenticado');
      return;
    }

    // Canal para notificações gerais (tabela notifications)
    _notificationsChannel = supabase
        .channel('user-notifications:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => _handleNotificationChange(payload),
        )
        .subscribe();

    // Canal para notificações agendadas (via pg_notify)
    _scheduledChannel = supabase.channel('scheduled-notifications:${user.id}');

    _scheduledChannel!
        .onBroadcast(
          event: 'send-scheduled-notifications',
          callback: (payload) => _handleScheduledNotification(payload),
        )
        .subscribe(
          (status, error) {
            print(
                '[RealtimeNotificationService] Scheduled channel status: $status',
            );
            if (error != null) {
              print(
                  '[RealtimeNotificationService] Scheduled channel error: $error',
              );
            }
          },
        );

    print('[RealtimeNotificationService] Subscriptions inicializadas');
  }

  /// Processa mudanças na tabela notifications
  void _handleNotificationChange(PostgresChangePayload payload) {
    print('[RealtimeNotificationService] Notificação recebida: $payload');

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        _showLocalNotificationFromDatabase(payload.newRecord);
        break;
      case PostgresChangeEvent.update:
        // Atualizar notificação local se necessário
        break;
      case PostgresChangeEvent.delete:
        // Remover notificação local se necessário
        break;
    }
  }

  /// Processa notificações agendadas via pg_notify
  void _handleScheduledNotification(RealtimeBroadcastPayload payload) {
    print(
        '[RealtimeNotificationService] Notificação agendada recebida: $payload',
    );

    try {
      final data = payload.payload as Map<String, dynamic>;
      
      // Verificar se já foi entregue
      final delivered = data['delivered'] as bool? ?? false;
      if (delivered) {
        print(
            '[RealtimeNotificationService] Notificação já foi entregue, ignorando',
        );
        return;
      }

      // Extrair dados da notificação
      final title = data['title'] as String? ?? 'Notificação';
      final message = data['message'] as String? ?? '';
      final deliverAt = data['deliverAt'] as String?;

      if (deliverAt == null) {
        print(
            '[RealtimeNotificationService] deliverAt não encontrado, ignorando',
        );
        return;
      }

      final deliverDateTime = DateTime.parse(deliverAt);
      final now = DateTime.now();

      // Se a notificação é para o futuro, agendar localmente
      if (deliverDateTime.isAfter(now)) {
        // Usar o NotificationService para agendar
        // Note: Isso requer integração adicional com o NotificationService
        print(
            '[RealtimeNotificationService] Notificação agendada para ${deliverDateTime.toIso8601String()}',
        );
      } else {
        // Se é para agora ou no passado, mostrar imediatamente
        _showNotification(title, message);
      }
    } catch (e) {
      print(
          '[RealtimeNotificationService] Erro ao processar notificação agendada: $e',
      );
    }
  }

  /// Mostra notificação local a partir de registro do banco
  void _showLocalNotificationFromDatabase(Map<String, dynamic> record) {
    final title = record['title'] as String? ?? 'Notificação';
    final message = record['message'] as String? ?? '';
    final type = record['type'] as String? ?? 'info';

    _showNotification(title, message);

    // Opcional: atualizar UI ou state management aqui
  }

  /// Mostra uma notificação local
  void _showNotification(String title, String message) {
    // Nota: flutter_local_notifications requer inicialização
    // Por enquanto, apenas logar
    // Em uma implementação completa, você chamaria:
    // _localNotificationService.showNotification(title: title, body: message);
    
    print('[RealtimeNotificationService] Mostrando notificação:');
    print('  Título: $title');
    print('  Mensagem: $message');
  }

  /// Desconecta todas as subscriptions
  Future<void> disconnect() async {
    if (_notificationsChannel != null) {
      await SupabaseConfig.client.removeChannel(_notificationsChannel!);
      _notificationsChannel = null;
    }

    if (_scheduledChannel != null) {
      await SupabaseConfig.client.removeChannel(_scheduledChannel!);
      _scheduledChannel = null;
    }

    print('[RealtimeNotificationService] Subscriptions desconectadas');
  }

  /// Reconecta as subscriptions (útil após login)
  Future<void> reconnect() async {
    await disconnect();
    await initialize();
  }
}

