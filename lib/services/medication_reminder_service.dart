import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medication.dart';
import '../database/database_helper.dart';

class MedicationReminderService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Initialize TTS
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _isInitialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could open medication page
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> scheduleMedicationReminders(Medication medication) async {
    await initialize();

    // Cancel existing notifications for this medication
    await cancelMedicationReminders(medication.id!);

    // Schedule new notifications
    for (int dayOfWeek in medication.daysOfWeek) {
      for (int reminderTime in medication.reminderTimes) {
        await _scheduleNotification(
          medication,
          dayOfWeek,
          reminderTime,
        );
      }
    }
  }

  static Future<void> _scheduleNotification(
    Medication medication,
    int dayOfWeek,
    int reminderTimeMinutes,
  ) async {
    final hour = reminderTimeMinutes ~/ 60;
    final minute = reminderTimeMinutes % 60;

    // Calculate next occurrence of this day and time
    DateTime scheduledDate = _getNextScheduledDate(dayOfWeek, hour, minute);

    final notificationId = '${medication.id}_${dayOfWeek}_${reminderTimeMinutes}'.hashCode;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for taking medications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      'Time for ${medication.name}',
      'Take ${medication.dosage} - ${medication.instructions}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'medication_${medication.id}',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static DateTime _getNextScheduledDate(int dayOfWeek, int hour, int minute) {
    final now = DateTime.now();
    final today = now.weekday % 7; // Convert to 0-6 format
    
    int daysUntilTarget = (dayOfWeek - today) % 7;
    if (daysUntilTarget == 0) {
      // Same day - check if time has passed
      final targetTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (targetTime.isBefore(now)) {
        daysUntilTarget = 7; // Next week
      }
    }

    final targetDate = now.add(Duration(days: daysUntilTarget));
    return DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
  }

  static Future<void> cancelMedicationReminders(int medicationId) async {
    // Cancel all notifications for this medication
    final List<PendingNotificationRequest> pendingNotifications = 
        await _notifications.pendingNotificationRequests();
    
    for (var notification in pendingNotifications) {
      if (notification.payload?.startsWith('medication_$medicationId') == true) {
        await _notifications.cancel(notification.id);
      }
    }
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  static Future<void> speakMedicationReminder(Medication medication) async {
    await initialize();

    final message = 'Time to take your ${medication.name}. '
        'Take ${medication.dosage}. '
        'Instructions: ${medication.instructions}';

    await _tts.speak(message);
  }

  static Future<void> speakConfirmation(String medicationName) async {
    await initialize();

    final message = 'Great! You have taken your $medicationName. Keep up the good work!';
    await _tts.speak(message);
  }

  static Future<void> showMedicationTakenDialog(Medication medication) async {
    await initialize();

    // Show a notification confirming medication was taken
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_confirmation',
      'Medication Confirmation',
      channelDescription: 'Confirmation when medications are taken',
      importance: Importance.low,
      priority: Priority.low,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      medication.id!,
      'Medication Taken',
      'You have taken ${medication.name}',
      notificationDetails,
    );

    // Speak confirmation
    await speakConfirmation(medication.name);
  }

  static Future<List<PendingNotificationRequest>> getPendingReminders() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> rescheduleAllReminders() async {
    await initialize();
    
    // Cancel all existing reminders
    await cancelAllReminders();
    
    // Get all active medications and reschedule
    final dbHelper = DatabaseHelper();
    final medications = await dbHelper.getActiveMedications();
    
    for (var medication in medications) {
      await scheduleMedicationReminders(medication);
    }
  }
}
