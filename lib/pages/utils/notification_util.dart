import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtil {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _init = false;

  void initialize(DidReceiveNotificationResponseCallback? onTap) {
    if (_init && !(Platform.isAndroid || Platform.isIOS)) return;
    _init = true;
    _notificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification),
      ),
      onDidReceiveNotificationResponse: onTap,
    );
  }

  Future<void> showNotification({
    String? title,
    String? body,
    DidReceiveNotificationResponseCallback? onTap,
  }) async {
    if (!Platform.isAndroid || !Platform.isIOS) return;
    initialize(onTap);
    await _notificationsPlugin.show(
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
