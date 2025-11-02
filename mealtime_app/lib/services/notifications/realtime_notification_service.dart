import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:mealtime_app/services/notifications/notification_service.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';

/// Serviço para escutar notificações em tempo real do Supabase
/// Integra REALTIME subscriptions com o sistema de notificações locais
class RealtimeNotificationService {
  RealtimeChannel? _notificationsChannel;
  RealtimeChannel? _scheduledChannel;
  final NotificationService _localNotificationService;

  /// Callback opcional chamado quando uma notificação é recebida
  /// Útil para atualizar UI, badges, etc.
  VoidCallback? onNotificationReceived;

  RealtimeNotificationService(this._localNotificationService);

  /// Inicializa as subscriptions REALTIME para notificações
  Future<void> initialize() async {
    developer.log(
      'Iniciando inicialização do RealtimeNotificationService',
      name: 'RealtimeNotificationService',
    );

    // Verificar se o NotificationService está inicializado
    final isNotificationServiceInitialized =
        await _checkNotificationServiceStatus();
    if (!isNotificationServiceInitialized) {
      developer.log(
        'NotificationService não está inicializado, tentando inicializar...',
        name: 'RealtimeNotificationService',
      );
      final initialized = await _localNotificationService.initialize();
      if (!initialized) {
        developer.log(
          'Falha ao inicializar NotificationService',
          name: 'RealtimeNotificationService',
        );
        return;
      }
      developer.log(
        'NotificationService inicializado com sucesso',
        name: 'RealtimeNotificationService',
      );
    } else {
      developer.log(
        'NotificationService já está inicializado',
        name: 'RealtimeNotificationService',
      );
    }

    final supabase = SupabaseConfig.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      developer.log(
        'Usuário não autenticado',
        name: 'RealtimeNotificationService',
      );
      return;
    }

    developer.log(
      'Inicializando para usuário: ${user.id}',
      name: 'RealtimeNotificationService',
    );

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
          callback: (payload) async {
            developer.log(
              'Notificação recebida via callback',
              name: 'RealtimeNotificationService',
            );
            await _handleNotificationChange(payload);
          },
        )
        .subscribe((status, error) {
          developer.log(
            'Notifications channel status: $status',
            name: 'RealtimeNotificationService',
          );
          if (error != null) {
            developer.log(
              'Notifications channel error: $error',
              name: 'RealtimeNotificationService',
              error: error,
            );
          }
          if (status == RealtimeSubscribeStatus.subscribed) {
            developer.log(
              'Subscrito com sucesso à tabela notifications',
              name: 'RealtimeNotificationService',
            );
          }
        });

    // Canal para notificações agendadas (via pg_notify)
    _scheduledChannel = supabase.channel('scheduled-notifications:${user.id}');

    _scheduledChannel!
        .onBroadcast(
          event: 'send-scheduled-notifications',
          callback: (payload) async {
            await _handleScheduledNotification(payload);
          },
        )
        .subscribe(
          (status, error) {
            developer.log(
              'Scheduled channel status: $status',
              name: 'RealtimeNotificationService',
            );
            if (error != null) {
              developer.log(
                'Scheduled channel error: $error',
                name: 'RealtimeNotificationService',
                error: error,
              );
            }
          },
        );

    developer.log(
      'Inicialização concluída',
      name: 'RealtimeNotificationService',
    );
  }

  /// Verifica o status do NotificationService
  Future<bool> _checkNotificationServiceStatus() async {
    try {
      // Usar isInitialized em vez de areNotificationsEnabled
      // pois queremos saber se o serviço está pronto, não apenas permissões
      if (!_localNotificationService.isInitialized) {
        return false;
      }
      final enabled = await _localNotificationService.areNotificationsEnabled();
      developer.log(
        'Permissões de notificação: ${enabled ? "Concedidas" : "Negadas"}',
        name: 'RealtimeNotificationService',
      );
      return enabled;
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao verificar status do NotificationService: $e',
        name: 'RealtimeNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Método de teste para verificar se as notificações funcionam
  Future<void> testNotification() async {
    developer.log(
      'Executando teste de notificação',
      name: 'RealtimeNotificationService',
    );

    try {
      final isInitialized = await _checkNotificationServiceStatus();
      if (!isInitialized) {
        developer.log(
          'NotificationService não inicializado, tentando inicializar...',
          name: 'RealtimeNotificationService',
        );
        final initialized = await _localNotificationService.initialize();
        if (!initialized) {
          developer.log(
            'Não foi possível inicializar NotificationService',
            name: 'RealtimeNotificationService',
          );
          return;
        }
      }

      await _showNotification(
        'Teste de Notificação',
        'Se você está vendo isso, as notificações estão funcionando! 🎉',
      );

      developer.log(
        'Notificação de teste enviada',
        name: 'RealtimeNotificationService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Erro no teste: $e',
        name: 'RealtimeNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Processa mudanças na tabela notifications
  Future<void> _handleNotificationChange(
    PostgresChangePayload payload,
  ) async {
    developer.log(
      'Notificação recebida: ${payload.eventType}',
      name: 'RealtimeNotificationService',
    );

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        await _showLocalNotificationFromDatabase(payload.newRecord);
        break;
      case PostgresChangeEvent.update:
        // Atualizar notificação local se necessário
        developer.log(
          'Notificação atualizada (não implementado)',
          name: 'RealtimeNotificationService',
        );
        break;
      case PostgresChangeEvent.delete:
        // Remover notificação local se necessário
        developer.log(
          'Notificação deletada (não implementado)',
          name: 'RealtimeNotificationService',
        );
        break;
      case PostgresChangeEvent.all:
        // Quando usando PostgresChangeEvent.all, tratar baseado no tipo real do evento
        // Normalmente será insert, update ou delete, mas isso serve como fallback
        await _showLocalNotificationFromDatabase(payload.newRecord);
        break;
    }
  }

  /// Processa notificações agendadas via pg_notify
  Future<void> _handleScheduledNotification(dynamic payload) async {
    developer.log(
      'Notificação agendada recebida',
      name: 'RealtimeNotificationService',
    );

    try {
      // O payload do onBroadcast vem como Map<String, dynamic> diretamente
      final data = payload is Map<String, dynamic>
          ? payload
          : (payload as Map)['payload'] as Map<String, dynamic>? ??
              <String, dynamic>{};

      // Verificar se já foi entregue
      final delivered = data['delivered'] as bool? ?? false;
      if (delivered) {
        developer.log(
          'Notificação já foi entregue, ignorando',
          name: 'RealtimeNotificationService',
        );
        return;
      }

      // Extrair dados da notificação
      final title = data['title'] as String? ?? 'Notificação';
      final message = data['message'] as String? ?? '';
      final deliverAt = data['deliverAt'] as String?;

      if (deliverAt == null) {
        developer.log(
          'deliverAt não encontrado, ignorando',
          name: 'RealtimeNotificationService',
        );
        return;
      }

      final deliverDateTime = DateTime.parse(deliverAt);
      final now = DateTime.now();

      // Se a notificação é para o futuro, agendar localmente
      if (deliverDateTime.isAfter(now)) {
        // Usar o NotificationService para agendar
        // Note: Isso requer integração adicional com o NotificationService
        developer.log(
          'Notificação agendada para ${deliverDateTime.toIso8601String()}',
          name: 'RealtimeNotificationService',
        );
        // TODO: Implementar agendamento usando NotificationService
      } else {
        // Se é para agora ou no passado, mostrar imediatamente
        await _showNotification(title, message);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao processar notificação agendada: $e',
        name: 'RealtimeNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Mostra notificação local a partir de registro do banco
  Future<void> _showLocalNotificationFromDatabase(
    Map<String, dynamic> record,
  ) async {
    developer.log(
      'Processando notificação do banco de dados',
      name: 'RealtimeNotificationService',
    );

    final title = record['title'] as String? ?? 'Notificação';
    final message = record['message'] as String? ?? '';
    final type = record['type'] as String? ?? 'info';

    developer.log(
      'Notificação extraída: título="$title", mensagem="$message", tipo="$type"',
      name: 'RealtimeNotificationService',
    );

    // Verificar se o NotificationService está inicializado antes de mostrar
    final isInitialized = await _checkNotificationServiceStatus();
    if (!isInitialized) {
      developer.log(
        'NotificationService não inicializado, tentando inicializar...',
        name: 'RealtimeNotificationService',
      );
      final initialized = await _localNotificationService.initialize();
      if (!initialized) {
        developer.log(
          'Não foi possível inicializar NotificationService',
          name: 'RealtimeNotificationService',
        );
        return;
      }
    }

    await _showNotification(title, message);

    // Notificar callback se registrado (útil para atualizar badges, UI, etc)
    onNotificationReceived?.call();
  }

  /// Mostra uma notificação local
  Future<void> _showNotification(String title, String message) async {
    developer.log(
      'Exibindo notificação: título="$title", mensagem="$message"',
      name: 'RealtimeNotificationService',
    );

    try {
      // Verificar permissões antes de tentar exibir
      final hasPermission =
          await _localNotificationService.areNotificationsEnabled();
      if (!hasPermission) {
        developer.log(
          'Permissões de notificação não concedidas',
          name: 'RealtimeNotificationService',
        );
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'mealtime_feeding_reminders',
        'Lembretes de Alimentação',
        channelDescription: 'Notificações de lembretes de refeições dos gatos',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/launcher_icon',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Usar o método show do NotificationService
      await _localNotificationService.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: message,
        notificationDetails: notificationDetails,
      );

      developer.log(
        'Notificação exibida com sucesso',
        name: 'RealtimeNotificationService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao exibir notificação local: $e',
        name: 'RealtimeNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
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

    developer.log(
      'Subscriptions desconectadas',
      name: 'RealtimeNotificationService',
    );
  }

  /// Reconecta as subscriptions (útil após login)
  Future<void> reconnect() async {
    await disconnect();
    await initialize();
  }
}
