import '../models/appointment.dart';
import '../models/doctor.dart';
import '../database/database_helper.dart';
import 'medication_reminder_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppointmentService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // Book a new appointment
  static Future<int> bookAppointment(Appointment appointment) async {
    try {
      // Insert appointment into database
      final appointmentId = await _dbHelper.insertAppointment(appointment);
      
      // Schedule reminder notification
      await _scheduleAppointmentReminder(appointment);
      
      return appointmentId;
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }

  // Schedule appointment reminder
  static Future<void> _scheduleAppointmentReminder(Appointment appointment) async {
    try {
      // Calculate reminder time (24 hours before appointment)
      final appointmentDateTime = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
        int.parse(appointment.appointmentTime.split(':')[0]),
        int.parse(appointment.appointmentTime.split(':')[1]),
      );
      
      final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
      
      // Only schedule if reminder time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        await MedicationReminderService.initialize();
        
        // Create a custom notification for appointment reminder
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'appointment_reminders',
          'Appointment Reminders',
          channelDescription: 'Reminders for upcoming appointments',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );

        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
        );

        final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
        await notifications.schedule(
          appointment.id!,
          'Appointment Reminder',
          'You have an appointment with Dr. ${await _getDoctorName(appointment.doctorId)} tomorrow at ${appointment.appointmentTime}',
          reminderTime,
          notificationDetails,
          payload: 'appointment_${appointment.id}',
        );
      }
    } catch (e) {
      print('Error scheduling appointment reminder: $e');
    }
  }

  // Get doctor name by ID
  static Future<String> _getDoctorName(int doctorId) async {
    try {
      final doctor = await _dbHelper.getDoctorById(doctorId);
      return doctor?.name ?? 'Unknown Doctor';
    } catch (e) {
      return 'Unknown Doctor';
    }
  }

  // Get all appointments
  static Future<List<Appointment>> getAllAppointments() async {
    try {
      return await _dbHelper.getAllAppointments();
    } catch (e) {
      throw Exception('Failed to get appointments: $e');
    }
  }

  // Get upcoming appointments
  static Future<List<Appointment>> getUpcomingAppointments() async {
    try {
      return await _dbHelper.getUpcomingAppointments();
    } catch (e) {
      throw Exception('Failed to get upcoming appointments: $e');
    }
  }

  // Get today's appointments
  static Future<List<Appointment>> getTodayAppointments() async {
    try {
      return await _dbHelper.getTodayAppointments();
    } catch (e) {
      throw Exception('Failed to get today\'s appointments: $e');
    }
  }

  // Get appointments by status
  static Future<List<Appointment>> getAppointmentsByStatus(AppointmentStatus status) async {
    try {
      return await _dbHelper.getAppointmentsByStatus(status);
    } catch (e) {
      throw Exception('Failed to get appointments by status: $e');
    }
  }

  // Update appointment status
  static Future<void> updateAppointmentStatus(int appointmentId, AppointmentStatus status) async {
    try {
      await _dbHelper.updateAppointmentStatus(appointmentId, status);
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }

  // Cancel appointment
  static Future<void> cancelAppointment(int appointmentId) async {
    try {
      await _dbHelper.updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
      
      // Cancel any scheduled reminders
      final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
      await notifications.cancel(appointmentId);
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  // Reschedule appointment
  static Future<void> rescheduleAppointment(int appointmentId, DateTime newDate, String newTime) async {
    try {
      // Get current appointment
      final appointments = await _dbHelper.getAllAppointments();
      final appointment = appointments.firstWhere((apt) => apt.id == appointmentId);
      
      // Update appointment with new date and time
      final updatedAppointment = appointment.copyWith(
        appointmentDate: newDate,
        appointmentTime: newTime,
        status: AppointmentStatus.rescheduled,
      );
      
      await _dbHelper.updateAppointment(updatedAppointment);
      
      // Cancel old reminder and schedule new one
      final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
      await notifications.cancel(appointmentId);
      await _scheduleAppointmentReminder(updatedAppointment);
    } catch (e) {
      throw Exception('Failed to reschedule appointment: $e');
    }
  }

  // Complete appointment
  static Future<void> completeAppointment(int appointmentId, {String? prescription, String? diagnosis}) async {
    try {
      // Get current appointment
      final appointments = await _dbHelper.getAllAppointments();
      final appointment = appointments.firstWhere((apt) => apt.id == appointmentId);
      
      // Update appointment as completed
      final updatedAppointment = appointment.copyWith(
        status: AppointmentStatus.completed,
        prescription: prescription,
        diagnosis: diagnosis,
      );
      
      await _dbHelper.updateAppointment(updatedAppointment);
    } catch (e) {
      throw Exception('Failed to complete appointment: $e');
    }
  }

  // Delete appointment
  static Future<void> deleteAppointment(int appointmentId) async {
    try {
      await _dbHelper.deleteAppointment(appointmentId);
      
      // Cancel any scheduled reminders
      final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
      await notifications.cancel(appointmentId);
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  // Send appointment reminders
  static Future<void> sendAppointmentReminders() async {
    try {
      final appointments = await _dbHelper.getAppointmentsNeedingReminders();
      
      for (final appointment in appointments) {
        // Send notification
        await _sendAppointmentReminderNotification(appointment);
        
        // Mark reminder as sent
        await _dbHelper.markReminderSent(appointment.id!);
      }
    } catch (e) {
      print('Error sending appointment reminders: $e');
    }
  }

  // Send appointment reminder notification
  static Future<void> _sendAppointmentReminderNotification(Appointment appointment) async {
    try {
      await MedicationReminderService.initialize();
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'appointment_reminders',
        'Appointment Reminders',
        channelDescription: 'Reminders for upcoming appointments',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
      final doctorName = await _getDoctorName(appointment.doctorId);
      
      await notifications.show(
        appointment.id!,
        'Appointment Reminder',
        'You have an appointment with Dr. $doctorName ${appointment.formattedDateTime}',
        notificationDetails,
        payload: 'appointment_${appointment.id}',
      );
    } catch (e) {
      print('Error sending appointment reminder notification: $e');
    }
  }

  // Get appointment statistics
  static Future<Map<String, int>> getAppointmentStats() async {
    try {
      final appointments = await _dbHelper.getAllAppointments();
      
      return {
        'total': appointments.length,
        'scheduled': appointments.where((apt) => apt.status == AppointmentStatus.scheduled).length,
        'confirmed': appointments.where((apt) => apt.status == AppointmentStatus.confirmed).length,
        'completed': appointments.where((apt) => apt.status == AppointmentStatus.completed).length,
        'cancelled': appointments.where((apt) => apt.status == AppointmentStatus.cancelled).length,
        'upcoming': appointments.where((apt) => apt.isUpcoming).length,
        'today': appointments.where((apt) => apt.isToday).length,
      };
    } catch (e) {
      throw Exception('Failed to get appointment statistics: $e');
    }
  }

  // Check for appointment conflicts
  static Future<bool> hasAppointmentConflict(int doctorId, DateTime date, String time) async {
    try {
      final appointments = await _dbHelper.getAppointmentsByDoctor(doctorId);
      
      final appointmentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(time.split(':')[0]),
        int.parse(time.split(':')[1]),
      );
      
      // Check for conflicts (same doctor, same date/time, not cancelled)
      for (final appointment in appointments) {
        if (appointment.status == AppointmentStatus.cancelled) continue;
        
        final existingDateTime = DateTime(
          appointment.appointmentDate.year,
          appointment.appointmentDate.month,
          appointment.appointmentDate.day,
          int.parse(appointment.appointmentTime.split(':')[0]),
          int.parse(appointment.appointmentTime.split(':')[1]),
        );
        
        // Check if times overlap (assuming 30-minute appointments)
        final timeDifference = appointmentDateTime.difference(existingDateTime).abs();
        if (timeDifference.inMinutes < 30) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      throw Exception('Failed to check appointment conflicts: $e');
    }
  }

  // Get available time slots for a doctor on a specific date
  static Future<List<String>> getAvailableTimeSlots(int doctorId, DateTime date) async {
    try {
      final doctor = await _dbHelper.getDoctorById(doctorId);
      if (doctor == null) return [];
      
      // Check if doctor is available on this day
      final dayOfWeek = date.weekday % 7; // Convert to 0-6 format
      if (!doctor.isAvailableOnDay(dayOfWeek)) return [];
      
      // Get existing appointments for this doctor on this date
      final appointments = await _dbHelper.getAppointmentsByDoctor(doctorId);
      final existingAppointments = appointments.where((apt) {
        final aptDate = DateTime(
          apt.appointmentDate.year,
          apt.appointmentDate.month,
          apt.appointmentDate.day,
        );
        final checkDate = DateTime(date.year, date.month, date.day);
        return aptDate.isAtSameMomentAs(checkDate) && apt.status != AppointmentStatus.cancelled;
      }).toList();
      
      // Generate time slots (9 AM to 5 PM, 30-minute intervals)
      final List<String> availableSlots = [];
      final List<String> allSlots = [];
      
      for (int hour = 9; hour < 17; hour++) {
        allSlots.add('${hour.toString().padLeft(2, '0')}:00');
        allSlots.add('${hour.toString().padLeft(2, '0')}:30');
      }
      
      // Filter out booked slots
      for (final slot in allSlots) {
        bool isBooked = false;
        for (final appointment in existingAppointments) {
          if (appointment.appointmentTime == slot) {
            isBooked = true;
            break;
          }
        }
        if (!isBooked) {
          availableSlots.add(slot);
        }
      }
      
      return availableSlots;
    } catch (e) {
      throw Exception('Failed to get available time slots: $e');
    }
  }
}
