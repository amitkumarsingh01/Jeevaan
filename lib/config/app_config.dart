// Configuration file for API keys and settings
class AppConfig {
  // Google Maps API Key
  // Replace with your actual Google Maps API key
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  
  // Google Places API Key
  // Replace with your actual Google Places API key
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY_HERE';
  
  // Default search radius in meters
  static const double defaultSearchRadius = 5000.0; // 5km
  
  // Maximum number of results per category
  static const int maxResultsPerCategory = 20;
  
  // Emergency services search radius in meters
  static const double emergencySearchRadius = 10000.0; // 10km
  
  // Healthcare services search radius in meters
  static const double healthcareSearchRadius = 5000.0; // 5km
  
  // API endpoints
  static const String googleMapsBaseUrl = 'https://maps.googleapis.com/maps/api';
  static const String placesNearbyUrl = '$googleMapsBaseUrl/place/nearbysearch/json';
  static const String placesTextSearchUrl = '$googleMapsBaseUrl/place/textsearch/json';
  static const String placesDetailsUrl = '$googleMapsBaseUrl/place/details/json';
  
  // App settings
  static const String appName = 'Jeevaan';
  static const String appVersion = '1.0.0';
  
  // Location settings
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;
  
  // Notification settings
  static const String notificationChannelId = 'jeevaan_notifications';
  static const String notificationChannelName = 'Jeevaan Notifications';
  static const String notificationChannelDescription = 'Notifications from Jeevaan app';
  
  // Database settings
  static const String databaseName = 'jeevaan.db';
  static const int databaseVersion = 1;
  
  // Validation methods
  static bool isApiKeyConfigured() {
    return googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE' &&
           googlePlacesApiKey != 'YOUR_GOOGLE_PLACES_API_KEY_HERE';
  }
  
  static String getApiKeyStatus() {
    if (isApiKeyConfigured()) {
      return 'API keys are configured';
    } else {
      return 'API keys need to be configured';
    }
  }
}
