import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'email_service.dart';
import 'medication_reminder_service.dart';
import '../models/medication.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MedicationReminderService.initialize();
    _isInitialized = true;
  }

  /// Send both local notification and email
  static Future<void> sendNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    bool sendEmail = true,
    String? emailSubject,
    String? emailBody,
  }) async {
    await initialize();
    
    // Send local notification
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'general_notifications',
        'General Notifications',
        channelDescription: 'General notifications from Jeevaan app',
        importance: importance,
        priority: priority,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error sending local notification: $e');
    }

    // Send email if enabled
    if (sendEmail) {
      try {
        await EmailService.sendNotificationEmail(
          subject: emailSubject ?? title,
          message: emailBody ?? body,
        );
      } catch (e) {
        print('Error sending notification email: $e');
        // Don't fail if email fails
      }
    }
  }

  /// Send appointment booked notification
  static Future<void> notifyAppointmentBooked({
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    final title = 'Appointment Booked';
    final body = 'Your appointment with Dr. $doctorName on $appointmentDate at $appointmentTime has been confirmed.';
    
    final emailBody = '''
Dear User,

Your appointment has been successfully booked!

Doctor: Dr. $doctorName
Date: $appointmentDate
Time: $appointmentTime

We look forward to seeing you!

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
    );
  }

  /// Send appointment cancelled notification
  static Future<void> notifyAppointmentCancelled({
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    final title = 'Appointment Cancelled';
    final body = 'Your appointment with Dr. $doctorName on $appointmentDate at $appointmentTime has been cancelled.';
    
    final emailBody = '''
Dear User,

Your appointment has been cancelled.

Doctor: Dr. $doctorName
Date: $appointmentDate
Time: $appointmentTime

If you need to reschedule, please book a new appointment.

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
    );
  }

  /// Send appointment completed notification
  static Future<void> notifyAppointmentCompleted({
    required String doctorName,
    required String appointmentDate,
  }) async {
    final title = 'Appointment Completed';
    final body = 'Your appointment with Dr. $doctorName on $appointmentDate has been marked as completed.';
    
    final emailBody = '''
Dear User,

Your appointment has been completed.

Doctor: Dr. $doctorName
Date: $appointmentDate

Thank you for using Jeevaan Health Companion!

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
    );
  }

  /// Send order placed notification
  static Future<void> notifyOrderPlaced({
    required String orderNumber,
    required double totalAmount,
    required String deliveryAddress,
    String? customerName,
    String? customerEmail,
    List<Map<String, dynamic>>? orderItems,
  }) async {
    final title = 'Order Placed Successfully';
    final body = 'Your order #$orderNumber has been placed. Total: ₹${totalAmount.toStringAsFixed(2)}';
    
    // Build order items list for email
    String itemsList = '';
    String itemsListHtml = '';
    if (orderItems != null && orderItems.isNotEmpty) {
      itemsList = '\nOrder Items:\n';
      itemsListHtml = '<table style="width: 100%; border-collapse: collapse; margin: 15px 0;">';
      itemsListHtml += '<tr style="background-color: #f0f0f0;"><th style="padding: 10px; text-align: left; border: 1px solid #ddd;">Item</th><th style="padding: 10px; text-align: center; border: 1px solid #ddd;">Qty</th><th style="padding: 10px; text-align: right; border: 1px solid #ddd;">Price</th></tr>';
      
      for (final item in orderItems) {
        final medicineName = item['medicine']?.name ?? item['medicineName'] ?? 'Unknown';
        final quantity = item['quantity'] ?? 0;
        final price = item['medicine']?.price ?? item['price'] ?? 0.0;
        final itemTotal = (price * quantity);
        itemsList += '• $medicineName x $quantity - ₹${itemTotal.toStringAsFixed(2)}\n';
        itemsListHtml += '<tr><td style="padding: 10px; border: 1px solid #ddd;">$medicineName</td><td style="padding: 10px; text-align: center; border: 1px solid #ddd;">$quantity</td><td style="padding: 10px; text-align: right; border: 1px solid #ddd;">₹${itemTotal.toStringAsFixed(2)}</td></tr>';
      }
      itemsListHtml += '</table>';
    }
    
    final emailBody = '''
Dear ${customerName ?? 'User'},

Your order has been placed successfully!

Order Number: $orderNumber
Total Amount: ₹${totalAmount.toStringAsFixed(2)}
Delivery Address: $deliveryAddress
$itemsList
We will process your order and notify you once it's shipped.

Thank you for your purchase!

Best regards,
Jeevaan Health Companion
''';

    final emailHtmlBody = '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; background-color: #f9f9f9; }
    .order-info { background-color: white; padding: 15px; margin: 10px 0; border-left: 4px solid #4CAF50; }
    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>🛒 Order Placed Successfully</h2>
    </div>
    <div class="content">
      <p>Dear ${customerName ?? 'User'},</p>
      <p>Your order has been placed successfully!</p>
      <div class="order-info">
        <p><strong>Order Number:</strong> $orderNumber</p>
        <p><strong>Total Amount:</strong> ₹${totalAmount.toStringAsFixed(2)}</p>
        <p><strong>Delivery Address:</strong> $deliveryAddress</p>
      </div>
      $itemsListHtml
      <p>We will process your order and notify you once it's shipped.</p>
      <p>Thank you for your purchase!</p>
    </div>
    <div class="footer">
      <p>Jeevaan Health Companion</p>
    </div>
  </div>
</body>
</html>
''';

    // Send to specific email if provided, otherwise use default
    if (customerEmail != null && customerEmail.isNotEmpty) {
      try {
        await EmailService.sendEmail(
          to: customerEmail,
          subject: title,
          body: emailBody,
          htmlBody: emailHtmlBody,
        );
        print('Order confirmation email sent to $customerEmail');
      } catch (e) {
        print('Error sending order email to $customerEmail: $e');
      }
    }

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
      sendEmail: customerEmail == null, // Only send default email if no specific email provided
    );
  }

  /// Send order status update notification
  static Future<void> notifyOrderStatusUpdate({
    required String orderNumber,
    required String status,
    String? trackingNumber,
  }) async {
    final title = 'Order Status Updated';
    final body = 'Your order #$orderNumber status has been updated to: $status';
    
    var emailBody = '''
Dear User,

Your order status has been updated.

Order Number: $orderNumber
Status: $status
''';

    if (trackingNumber != null) {
      emailBody += 'Tracking Number: $trackingNumber\n';
    }

    emailBody += '''
Thank you for your patience!

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
    );
  }

  /// Send medication added notification
  static Future<void> notifyMedicationAdded({
    required String medicationName,
  }) async {
    final title = 'Medication Added';
    final body = 'Medication "$medicationName" has been added to your list. Reminders have been scheduled.';
    
    final emailBody = '''
Dear User,

A new medication has been added to your list.

Medication: $medicationName

Reminders have been scheduled. You will receive notifications at the specified times.

Stay healthy!

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
    );
  }

  /// Send medication updated notification
  static Future<void> notifyMedicationUpdated({
    required String medicationName,
  }) async {
    final title = 'Medication Updated';
    final body = 'Medication "$medicationName" has been updated. Reminders have been rescheduled.';
    
    final emailBody = '''
Dear User,

Your medication has been updated.

Medication: $medicationName

Reminders have been rescheduled according to the new settings.

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
    );
  }

  /// Send medication deleted notification
  static Future<void> notifyMedicationDeleted({
    required String medicationName,
  }) async {
    final title = 'Medication Deleted';
    final body = 'Medication "$medicationName" has been removed from your list.';
    
    final emailBody = '''
Dear User,

A medication has been removed from your list.

Medication: $medicationName

All reminders for this medication have been cancelled.

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
    );
  }

  /// Send medication taken notification (with email)
  static Future<void> notifyMedicationTaken({
    required String medicationName,
  }) async {
    await MedicationReminderService.showMedicationTakenDialog(
      Medication(
        id: 0,
        name: medicationName,
        dosage: '',
        instructions: '',
        reminderTimes: [],
        daysOfWeek: [],
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );

    // Also send email
    try {
      await EmailService.sendNotificationEmail(
        subject: 'Medication Taken: $medicationName',
        message: '''
Dear User,

Great job! You have taken your medication.

Medication: $medicationName

Keep up the good work and stay healthy!

Best regards,
Jeevaan Health Companion
''',
      );
    } catch (e) {
      print('Error sending medication taken email: $e');
    }
  }

  /// Send emergency alert notification
  static Future<void> notifyEmergencyAlert({
    required String contactName,
    required String contactPhone,
  }) async {
    final title = '🚨 Emergency Alert Sent';
    final body = 'Emergency alert has been sent to $contactName ($contactPhone)';
    
    final emailBody = '''
Dear User,

An emergency alert has been sent.

Contact: $contactName
Phone: $contactPhone

If this was not intentional, please contact your emergency contact immediately.

Stay safe!

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: 999999, // Special ID for emergency
      title: title,
      body: body,
      importance: Importance.max,
      priority: Priority.max,
      emailSubject: title,
      emailBody: emailBody,
    );
  }

  /// Send profile updated notification
  static Future<void> notifyProfileUpdated() async {
    final title = 'Profile Updated';
    final body = 'Your profile has been successfully updated.';
    
    final emailBody = '''
Dear User,

Your profile has been successfully updated.

If you did not make this change, please contact support immediately.

Best regards,
Jeevaan Health Companion
''';

    await sendNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      emailSubject: title,
      emailBody: emailBody,
    );
  }
}

