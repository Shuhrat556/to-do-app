import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/src/darwin_flutter_local_notifications_plugin.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/entities/task_entity.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _timezonesInitialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await init();
    if (Platform.isAndroid) return;
    await _plugin
        .resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleTaskNotification(
    Task task, {
    required bool playSound,
  }) async {
    final dueDate = task.dueDate;
    if (dueDate == null) return;
    await init();
    if (dueDate.isBefore(DateTime.now())) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'tasks_channel',
        'Vazifa eslatmalari',
        channelDescription: 'Vazifa muddatlari haqida ogohlantirish',
        importance: Importance.max,
        priority: Priority.max,
        playSound: playSound,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
      ),
    );

    final scheduledDate = tz.TZDateTime.from(dueDate, tz.local);
    await _plugin.zonedSchedule(
      _notificationId(task.id),
      'Vazifa vaqti tugadi',
      task.title,
      scheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(String taskId) async {
    await init();
    await _plugin.cancel(_notificationId(taskId));
  }

  Future<void> _initializeTimeZones() async {
    if (_timezonesInitialized) return;
    tz_data.initializeTimeZones();
    final String timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
    _timezonesInitialized = true;
  }

  int _notificationId(String taskId) => taskId.hashCode & 0x7fffffff;
}
