import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notif.initialize(settings);
  }

  static Future<void> showReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'oli_channel',
      'Oil Reminder',
      channelDescription: 'Reminder ganti oli',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notif.show(
      0,
      "⚠️ Waktunya Ganti Oli",
      "Motor kamu sudah masuk jadwal servis!",
      const NotificationDetails(android: androidDetails),
    );
  }
}