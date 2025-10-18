import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';

class SmsService {
  static Future<bool> _checkSmsPermission() async {
    // For SMS via url_launcher, we don't need explicit SMS permission
    // The system will handle it when opening the SMS app
    return true;
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
      
      if (position != null) {
        // Format location message
        final locationMessage = LocationService.formatLocationForSms(position);
        
        // Send SMS with location
        bool smsSent = await sendLocationSms(phoneNumber, locationMessage);
        
        // Also try to make a phone call
        final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        }
        
        return smsSent;
      } else {
        // If location is not available, send basic emergency message
        final basicMessage = '''🚨 EMERGENCY ALERT 🚨

I need help! Please call me immediately.

Sent from Jeevaan Emergency App''';
        
        bool smsSent = await sendEmergencySms(phoneNumber, basicMessage);
        
        // Try to make a phone call
        final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        }
        
        return smsSent;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> canSendSms() async {
    return await _checkSmsPermission();
  }
}
