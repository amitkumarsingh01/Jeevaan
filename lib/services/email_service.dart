import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class EmailService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // SMTP Configuration - Update these with your SMTP server details
  // For Gmail, you'll need to use an App Password
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const bool _smtpSecure = false; // Use TLS
  static const String _smtpUsername = '*******@gmail.com'; // Update with your email
  static const String _smtpPassword = '***************'; // Update with app password
  
  // Sender email and name
  static const String _senderEmail = '******@gmail.com'; // Update with your email
  static const String _senderName = 'Jeevaan Health Companion';

  /// Check if user has email configured
  static Future<String?> getUserEmail() async {
    try {
      // First try to get from current user's email
      final currentUser = AuthService.currentUser;
      if (currentUser != null && _isValidEmail(currentUser.email)) {
        return currentUser.email;
      }
      
      // If not available, try to get from user profile
      final profiles = await _dbHelper.getAllUserProfiles();
      if (profiles.isEmpty) return null;
      
      // Try to find profile matching current user email
      if (currentUser != null) {
        final matchingProfile = profiles.firstWhere(
          (p) => p.email == currentUser.email,
          orElse: () => profiles.first,
        );
        if (matchingProfile.email.isNotEmpty && _isValidEmail(matchingProfile.email)) {
          return matchingProfile.email;
        }
      }
      
      // Fallback to first profile
      final profile = profiles.first;
      if (profile.email.isEmpty || !_isValidEmail(profile.email)) {
        return null;
      }
      
      return profile.email;
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }
  
  /// Check if user email is configured and valid
  static Future<bool> isEmailConfigured() async {
    final email = await getUserEmail();
    return email != null && _isValidEmail(email);
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Send email using SMTP
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? htmlBody,
  }) async {
    try {
      // Validate email
      if (!_isValidEmail(to)) {
        print('Invalid email address: $to');
        return false;
      }

      // Create SMTP server
      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        ssl: _smtpSecure,
        username: _smtpUsername,
        password: _smtpPassword,
      );

      // Create message
      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(to)
        ..subject = subject
        ..text = body
        ..html = htmlBody ?? body;

      // Send email
      final sendReport = await send(message, smtpServer);
      
      if (sendReport.toString().contains('OK')) {
        print('Email sent successfully to $to');
        return true;
      } else {
        print('Failed to send email: $sendReport');
        return false;
      }
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  /// Send medication reminder email
  static Future<bool> sendMedicationReminderEmail({
    required String medicationName,
    required String dosage,
    required String instructions,
    required String reminderTime,
    required List<String> daysOfWeek,
  }) async {
    final userEmail = await getUserEmail();
    if (userEmail == null) {
      print('User email not configured');
      return false;
    }

    final subject = 'Medication Reminder: $medicationName';
    final body = '''
Dear User,

This is a reminder to take your medication:

Medication: $medicationName
Dosage: $dosage
Instructions: $instructions
Time: $reminderTime
Days: ${daysOfWeek.join(', ')}

Please take your medication as prescribed.

Stay healthy!
Jeevaan Health Companion
''';

    final htmlBody = '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; background-color: #f9f9f9; }
    .medication-info { background-color: white; padding: 15px; margin: 10px 0; border-left: 4px solid #4CAF50; }
    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>💊 Medication Reminder</h2>
    </div>
    <div class="content">
      <p>Dear User,</p>
      <p>This is a reminder to take your medication:</p>
      <div class="medication-info">
        <p><strong>Medication:</strong> $medicationName</p>
        <p><strong>Dosage:</strong> $dosage</p>
        <p><strong>Instructions:</strong> $instructions</p>
        <p><strong>Time:</strong> $reminderTime</p>
        <p><strong>Days:</strong> ${daysOfWeek.join(', ')}</p>
      </div>
      <p>Please take your medication as prescribed.</p>
      <p>Stay healthy!</p>
    </div>
    <div class="footer">
      <p>Jeevaan Health Companion</p>
    </div>
  </div>
</body>
</html>
''';

    return await sendEmail(
      to: userEmail,
      subject: subject,
      body: body,
      htmlBody: htmlBody,
    );
  }

  /// Send appointment reminder email
  static Future<bool> sendAppointmentReminderEmail({
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
    required String reason,
  }) async {
    final userEmail = await getUserEmail();
    if (userEmail == null) {
      print('User email not configured');
      return false;
    }

    final subject = 'Appointment Reminder: Dr. $doctorName';
    final body = '''
Dear User,

This is a reminder about your upcoming appointment:

Doctor: Dr. $doctorName
Date: $appointmentDate
Time: $appointmentTime
Reason: $reason

Please arrive on time for your appointment.

Best regards,
Jeevaan Health Companion
''';

    final htmlBody = '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #2196F3; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; background-color: #f9f9f9; }
    .appointment-info { background-color: white; padding: 15px; margin: 10px 0; border-left: 4px solid #2196F3; }
    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>📅 Appointment Reminder</h2>
    </div>
    <div class="content">
      <p>Dear User,</p>
      <p>This is a reminder about your upcoming appointment:</p>
      <div class="appointment-info">
        <p><strong>Doctor:</strong> Dr. $doctorName</p>
        <p><strong>Date:</strong> $appointmentDate</p>
        <p><strong>Time:</strong> $appointmentTime</p>
        <p><strong>Reason:</strong> $reason</p>
      </div>
      <p>Please arrive on time for your appointment.</p>
      <p>Best regards,</p>
    </div>
    <div class="footer">
      <p>Jeevaan Health Companion</p>
    </div>
  </div>
</body>
</html>
''';

    return await sendEmail(
      to: userEmail,
      subject: subject,
      body: body,
      htmlBody: htmlBody,
    );
  }

  /// Send general notification email
  static Future<bool> sendNotificationEmail({
    required String subject,
    required String message,
  }) async {
    final userEmail = await getUserEmail();
    if (userEmail == null) {
      print('User email not configured');
      return false;
    }

    return await sendEmail(
      to: userEmail,
      subject: subject,
      body: message,
    );
  }
}

