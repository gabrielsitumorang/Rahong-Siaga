import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelEmergencyId = 'flood_emergency_channel';
  static const String channelEmergencyName = 'Peringatan Darurat Banjir';

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    // Buat Channel Darurat
    const androidChannel = AndroidNotificationChannel(
      channelEmergencyId,
      channelEmergencyName,
      description: 'Peringatan Siaga dan Awas Bencana Banjir Desa Rahong',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }
  }

  static Future<void> showEmergencyNotification({
    required String title,
    required String body,
    required bool isEmergency,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelEmergencyId,
      channelEmergencyName,
      importance: isEmergency ? Importance.max : Importance.defaultImportance,
      priority: isEmergency ? Priority.max : Priority.defaultPriority,
      ongoing: isEmergency, // Tidak bisa di-swipe saat kondisi Awas
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
    );
  }
}

