import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/services/notifications/notification_service.dart';
import 'package:mealtime_app/services/notifications/realtime_notification_service.dart';

/// Serviço de notificações (exposto via Riverpod para evitar sl() na UI).
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return sl<NotificationService>();
});

/// Serviço de notificações em tempo real (exposto via Riverpod para evitar sl() na UI).
final realtimeNotificationServiceProvider =
    Provider<RealtimeNotificationService>((ref) {
  return sl<RealtimeNotificationService>();
});
