import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum NotificationType { time, location }

class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime dateTime;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'dateTime': dateTime.toIso8601String(),
    'type': type.toString(),
  };

  static AppNotification fromMap(Map m) {
    return AppNotification(
      id: m['id'] as int,
      title: m['title'] as String,
      body: m['body'] as String,
      dateTime: DateTime.parse(m['dateTime'] as String),
      type: NotificationType.time,
    );
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  static final List<AppNotification> appNotifications = [];

  static Box get _box => Hive.box('notificationsBox');

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: (response) {
          Get.toNamed('/notifications');
        });

    // Load saved notifications from Hive (key: 'items' => List<Map>)
    loadNotificationsFromHive();
  }

  static void loadNotificationsFromHive() {
    appNotifications.clear();
    final saved = _box.get('items', defaultValue: []) as List;
    for (var item in saved) {
      final map = Map<String, dynamic>.from(item);
      appNotifications.add(AppNotification.fromMap(map));
    }
  }

  static Future<void> addNotificationToHive(AppNotification notif) async {
    final saved = List<Map>.from(_box.get('items', defaultValue: []));
    saved.insert(0, notif.toMap()); // أحدث في المقدمة
    await _box.put('items', saved);
    loadNotificationsFromHive();
  }

  static Future<void> removeNotificationFromHive(int id) async {
    final saved = List<Map>.from(_box.get('items', defaultValue: []));
    saved.removeWhere((m) => (m['id'] as int) == id);
    await _box.put('items', saved);
    loadNotificationsFromHive();
  }

  // Scheduling function: يقوم بجدولة notification محليًا ويحفظها في Hive
  static Future<void> scheduleVisitNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    NotificationType type = NotificationType.time,
  }) async {
    final notif = AppNotification(
      id: id,
      title: title,
      body: body,
      dateTime: dateTime,
      type: type,
    );

    // خزّن في Hive (قائمة)
    await addNotificationToHive(notif);

    final androidDetails = AndroidNotificationDetails(
      'my_new_channel_id_2025',
      'Visit Reminders',
      channelDescription: 'Notifications for scheduled visits',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    final iosDetails = DarwinNotificationDetails(sound: 'notification_sound.mp3');

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      // uiLocalNotificationDateInterpretation:
      // UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    await removeNotificationFromHive(id);
  }
}
