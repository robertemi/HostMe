
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _notificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if local timezone cannot be determined
      tz.setLocalLocation(tz.UTC);
      print('Failed to set local timezone: $e');
    }

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    // For iOS, we can request permissions later or here.
    // Using default settings for now.
    const fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const fln.WindowsInitializationSettings initializationSettingsWindows = fln.WindowsInitializationSettings(
      appName: 'HostMe',
      appUserModelId: 'com.hostme.app',
      guid: '1f3f615c-9c2a-4d65-ab0a-3e6b8b7f0e3c',
    );

    const fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: fln.LinuxInitializationSettings(defaultActionName: 'Open'),
      windows: initializationSettingsWindows,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
        // Handle notification tap
        // You can add navigation logic here based on payload
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    // Android 13+ requires explicit permission
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const fln.AndroidNotificationDetails androidDetails =
        fln.AndroidNotificationDetails(
      'host_me_channel',
      'HostMe Notifications',
      channelDescription: 'General notifications for HostMe',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    );

    const fln.NotificationDetails details = fln.NotificationDetails(
      android: androidDetails,
      iOS: fln.DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    const fln.AndroidNotificationDetails androidDetails =
        fln.AndroidNotificationDetails(
      'host_me_scheduled',
      'HostMe Scheduled',
      channelDescription: 'Scheduled notifications for HostMe',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
    );

    const fln.NotificationDetails details = fln.NotificationDetails(
      android: androidDetails,
      iOS: fln.DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(delay),
      details,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Push/FCM integration has been removed; this service now only manages
  // local notifications (displaying and scheduling).
}
