import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'location_service.dart';

class SmsService {
  
  static Future<bool> _checkSmsPermission() async {
    // Check if SMS permission is granted
    final status = await Permission.sms.status;
    if (status.isGranted) {
      return true;
    }
    
    // Request SMS permission if not granted
    final result = await Permission.sms.request();
    return result.isGranted;
  }

  static Future<bool> sendEmergencySms(String phoneNumber, String message) async {
    try {
      // Open SMS app with pre-filled message
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        query: 'body=${Uri.encodeComponent(message)}',
      );
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendLocationSms(String phoneNumber, String locationMessage) async {
    try {
      // Open SMS app with pre-filled location message
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        query: 'body=${Uri.encodeComponent(locationMessage)}',
      );
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendEmergencyCallAndSms(String phoneNumber) async {
    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      
      String message;
      if (position != null) {
        // Format location message
        message = LocationService.formatLocationForSms(position);
      } else {
        // If location is not available, send basic emergency message
        message = '''🚨 EMERGENCY ALERT 🚨

I need help! Please call me immediately.

Sent from Jeevaan Emergency App''';
      }
      
      // Send SMS directly
      bool smsSent = await sendLocationSms(phoneNumber, message);
      
      // Also try to make a phone call
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
      
      return smsSent;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> canSendSms() async {
    return await _checkSmsPermission();
  }
}
