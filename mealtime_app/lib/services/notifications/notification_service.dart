import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:mealtime_app/features/schedules/domain/entities/schedule.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

/// Serviço de notificações locais
/// Gerencia o agendamento e exibição de notificações de refeições
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicializa o serviço de notificações
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Inicializar timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

      // Configuração para Android
      const androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // Configuração para iOS
      const iosInitializationSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      // Solicitar permissões
      await _requestPermissions();

      // Inicializar plugin
      final bool? initialized = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = initialized ?? false;

      if (_isInitialized) {
        // Configurar canal para Android
        await _setupAndroidChannel();
      }

      return _isInitialized;
    } catch (e) {
      print('[NotificationService] Erro ao inicializar: $e');
      return false;
    }
  }

  /// Solicita permissões necessárias para notificações
  Future<void> _requestPermissions() async {
    // Android 13+ precisa de permissão POST_NOTIFICATIONS
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Configura o canal de notificação para Android
  Future<void> _setupAndroidChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'mealtime_feeding_reminders',
      'Lembretes de Alimentação',
      description: 'Notificações de lembretes de refeições dos gatos',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Callback quando uma notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    // Aqui você pode implementar navegação ou outras ações
    // quando o usuário toca na notificação
    print(
        '[NotificationService] Notificação tocada: ${response.payload}',
    );
  }

  /// Agenda uma notificação de refeição baseada em um schedule
  Future<void> scheduleFeedingNotification({
    required Schedule schedule,
    required Cat cat,
    DateTime? specificDate,
  }) async {
    if (!_isInitialized) {
      print('[NotificationService] Serviço não inicializado');
      return;
    }

    if (!schedule.enabled) {
      print('[NotificationService] Schedule desabilitado, ignorando');
      return;
    }

    try {
      switch (schedule.type) {
        case ScheduleType.fixedTime:
          await _scheduleFixedTimeNotifications(
            schedule: schedule,
            cat: cat,
            specificDate: specificDate,
          );
          break;
        case ScheduleType.interval:
          // Para intervalos, não agendamos notificações específicas
          // pois são baseadas em eventos (ex: última refeição)
          print(
              '[NotificationService] Schedule de intervalo não suporta agendamento direto',
          );
          break;
      }
    } catch (e) {
      print('[NotificationService] Erro ao agendar notificação: $e');
    }
  }

  /// Agenda notificações para horários fixos
  Future<void> _scheduleFixedTimeNotifications({
    required Schedule schedule,
    required Cat cat,
    DateTime? specificDate,
  }) async {
    for (final timeString in schedule.times) {
      final timeParts = timeString.split(':');
      if (timeParts.length != 2) continue;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || minute == null) continue;

      // Se uma data específica foi fornecida, agendar para esse dia
      // Caso contrário, agendar para os próximos 30 dias
      final datesToSchedule = specificDate != null
          ? [specificDate]
          : _getNext30Days(hour, minute);

      for (final date in datesToSchedule) {
        final scheduledDate = tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        // Não agendar no passado
        if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
          continue;
        }

        await _scheduleNotification(
          id: _generateNotificationId(schedule.id, timeString, date),
          title: 'Hora da refeição! 🐱',
          body: 'É hora de alimentar ${cat.name}',
          scheduledDate: scheduledDate,
          payload: '${schedule.id}|${cat.id}|${timeString}',
        );
      }
    }
  }

  /// Gera uma lista de datas para os próximos 30 dias
  List<DateTime> _getNext30Days(int hour, int minute) {
    final now = DateTime.now();
    final dates = <DateTime>[];

    for (int i = 0; i < 30; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day + i,
        hour,
        minute,
      );
      dates.add(date);
    }

    return dates;
  }

  /// Agenda uma notificação específica
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mealtime_feeding_reminders',
      'Lembretes de Alimentação',
      channelDescription: 'Notificações de lembretes de refeições dos gatos',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/launcher_icon',
      actions: [
        AndroidNotificationAction(
          'complete',
          'Concluir',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'skip',
          'Pular',
          showsUserInterface: false,
        ),
      ],
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

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Gera um ID único para a notificação
  int _generateNotificationId(String scheduleId, String time, DateTime date) {
    // Usa hash do scheduleId + time + date para gerar ID único
    final hash = scheduleId.hashCode +
        time.hashCode +
        date.year.hashCode +
        date.month.hashCode +
        date.day.hashCode;
    return hash.abs() % 2147483647; // Limite máximo de int
  }

  /// Cancela todas as notificações de um schedule
  Future<void> cancelScheduleNotifications(String scheduleId) async {
    // Como não temos uma lista de IDs salvos, vamos cancelar todas
    // e reagendar apenas os schedules ativos
    // Isso é um trade-off - em uma implementação mais robusta,
    // você salvaria os IDs das notificações agendadas
    await cancelAllNotifications();
  }

  /// Cancela todas as notificações agendadas
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Agenda notificações para todos os schedules ativos de uma lista
  Future<void> scheduleNotificationsForSchedules({
    required List<Schedule> schedules,
    required List<Cat> cats,
  }) async {
    // Primeiro, cancela todas as notificações existentes
    await cancelAllNotifications();

    // Cria um mapa de cats por ID para acesso rápido
    final catsMap = {for (var cat in cats) cat.id: cat};

    // Agenda notificações para cada schedule ativo
    for (final schedule in schedules) {
      if (!schedule.enabled) continue;

      final cat = catsMap[schedule.catId];
      if (cat == null) {
        print(
            '[NotificationService] Gato não encontrado para schedule ${schedule.id}',
        );
        continue;
      }

      await scheduleFeedingNotification(
        schedule: schedule,
        cat: cat,
      );
    }
  }

  /// Verifica se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    return await Permission.notification.isGranted;
  }

  /// Abre as configurações do app para o usuário habilitar notificações
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }
}

