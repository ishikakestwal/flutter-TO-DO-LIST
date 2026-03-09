import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      // Initialize Timezones
      tz.initializeTimeZones();

      // Fix for emulators: Set a default location if local detection fails
      try {
        // You can use 'America/Detroit' or 'UTC' as a fallback
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (e) {
        print("Timezone Error: $e");
      }

      const AndroidInitializationSettings android =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      await notificationsPlugin.initialize(
        const InitializationSettings(android: android),
      );

      // Request permissions (Non-blocking)
      notificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

    } catch (e) {
      print("Notification Initialization failed: $e");
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    if (date.isBefore(DateTime.now())) return;

    try {
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(date, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print("Schedule Error: $e");
    }
  }
}
