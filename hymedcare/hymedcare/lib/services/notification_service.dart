import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../model/appointment_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);

    // Request permission for push notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Schedule appointment notification
  Future<void> scheduleAppointmentNotification(AppointmentModel appointment) async {
    // Schedule notification 1 day before
    final oneDayBefore = appointment.dateTime.subtract(const Duration(days: 1));
    await _scheduleNotification(
      id: appointment.id.hashCode,
      title: 'Upcoming Appointment Reminder',
      body: 'You have an appointment with Dr. ${appointment.doctorName} tomorrow at ${_formatTime(appointment.dateTime)}',
      scheduledDate: oneDayBefore,
    );

    // Schedule notification 1 hour before
    final oneHourBefore = appointment.dateTime.subtract(const Duration(hours: 1));
    await _scheduleNotification(
      id: appointment.id.hashCode + 1,
      title: 'Appointment Soon',
      body: 'Your appointment with Dr. ${appointment.doctorName} is in 1 hour',
      scheduledDate: oneHourBefore,
    );
  }

  // Cancel appointment notifications
  Future<void> cancelAppointmentNotifications(String appointmentId) async {
    await _localNotifications.cancel(appointmentId.hashCode);
    await _localNotifications.cancel(appointmentId.hashCode + 1);
  }

  // Schedule a notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_channel',
          'Appointment Notifications',
          channelDescription: 'Notifications for upcoming appointments',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'push_channel',
          'Push Notifications',
          channelDescription: 'Notifications from Firebase Cloud Messaging',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
}

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No need to show notification here as the system will automatically show it
  print('Handling background message: ${message.messageId}');
}
