import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
import 'email_service.dart';

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

    // Request exact alarm permission if needed (Android 12+)
    // Note: On Android 12+, this permission may need to be granted through Settings
    try {
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        final requestResult = await Permission.scheduleExactAlarm.request();
        if (!requestResult.isGranted) {
          print('Exact alarm permission not granted. Will use inexact alarms.');
          // User may need to grant permission in Settings
        }
      }
    } catch (e) {
      print('Could not check/request exact alarm permission: $e');
      // Continue anyway - will fall back to inexact alarms
    }

    // Cancel existing notifications for this medication
    await cancelMedicationReminders(medication.id!);

    // Schedule new notifications
    for (int dayOfWeek in medication.daysOfWeek) {
      for (int reminderTime in medication.reminderTimes) {
        try {
          await _scheduleNotification(
            medication,
            dayOfWeek,
            reminderTime,
          );
        } catch (e) {
          print('Error scheduling notification for ${medication.name}: $e');
          // Continue with other notifications even if one fails
        }
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

    // Check if exact alarm permission is granted
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle; // Default to inexact
    
    try {
      // Try to check exact alarm permission (Android 12+)
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isGranted) {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    } catch (e) {
      // On older Android versions or if permission check fails, use inexact
      print('Using inexact alarms (permission check failed): $e');
    }

    try {
      await _notifications.zonedSchedule(
        notificationId,
        'Time for ${medication.name}',
        'Take ${medication.dosage} - ${medication.instructions}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'medication_${medication.id}',
        androidScheduleMode: scheduleMode,
      );
      
      // Send email reminder if configured
      try {
        final hour = reminderTimeMinutes ~/ 60;
        final minute = reminderTimeMinutes % 60;
        final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        final dayName = dayNames[dayOfWeek];
        
        await EmailService.sendMedicationReminderEmail(
          medicationName: medication.name,
          dosage: medication.dosage,
          instructions: medication.instructions,
          reminderTime: timeStr,
          daysOfWeek: [dayName],
        );
      } catch (e) {
        print('Error sending medication reminder email: $e');
        // Don't fail notification if email fails
      }
    } catch (e) {
      // If exact alarm fails, try with inexact
      if (scheduleMode == AndroidScheduleMode.exactAllowWhileIdle) {
        print('Exact alarm failed, retrying with inexact: $e');
        try {
          await _notifications.zonedSchedule(
            notificationId,
            'Time for ${medication.name}',
            'Take ${medication.dosage} - ${medication.instructions}',
            tz.TZDateTime.from(scheduledDate, tz.local),
            notificationDetails,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: 'medication_${medication.id}',
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        } catch (e2) {
          print('Failed to schedule notification even with inexact alarms: $e2');
          // Don't rethrow - allow medication to be saved even if notification fails
        }
      } else {
        print('Failed to schedule notification: $e');
        // Don't rethrow - allow medication to be saved even if notification fails
      }
    }
  }

  static DateTime _getNextScheduledDate(int dayOfWeek, int hour, int minute) {
    final now = DateTime.now();
    // Convert DateTime.weekday (1-7, Monday=1, Sunday=7) to our format (0-6, Sunday=0, Saturday=6)
    final weekday = now.weekday;
    final today = weekday == 7 ? 0 : weekday - 1; // Sunday: 7->0, Monday: 1->1, etc.
    
    int daysUntilTarget = (dayOfWeek - today) % 7;
    if (daysUntilTarget < 0) {
      daysUntilTarget += 7;
    }
    
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
