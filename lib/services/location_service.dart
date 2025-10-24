import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      return false;
    }
    
    return false;
  }

  // Removed SMS permission check as we only send SMS, not read

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check location permission
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  // Removed canSendSms method as SMS permission is handled in SmsService

  static String formatLocationForSms(Position position) {
    final accuracy = position.accuracy;
    final timestamp = DateTime.now().toIso8601String();
    
    // Create Google Maps link
    final googleMapsLink = getGoogleMapsUrl(position);
    
    return '''🚨 EMERGENCY ALERT 🚨

I need help! This is my current location:

📍 Location: $googleMapsLink
🎯 Accuracy: ${accuracy.toStringAsFixed(1)} meters
⏰ Time: $timestamp

Please help me immediately!

Sent from Jeevaan Emergency App''';
  }

  static String getGoogleMapsUrl(Position position) {
    return 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
  }

  static String getLocationDescription(Position position) {
    return 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
  }
}
