import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtil {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> showNotification({
    String? title,
    String? body,
    DidReceiveBackgroundNotificationResponseCallback? onTap,
  }) async {
    _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification),
      ),
    );
    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'id',
          'flutter',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'payload',
    );
  }

  static Future onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    // 展示通知内容的 dialog.
  }
}
