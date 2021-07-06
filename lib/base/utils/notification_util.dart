import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtil {
  static FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> showNotification({
    String? title,
    String? body,
    SelectNotificationCallback? onTap,
  }) async {
    AndroidInitializationSettings android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: android);
    _notifications.initialize(initializationSettings, onSelectNotification: onTap);
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('id', 'flutter', 'a new notification', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notifications.show(0, title, body, platformChannelSpecifics, payload: 'payload');
  }
}
