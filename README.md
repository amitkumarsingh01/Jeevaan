# Jeevaan - Health Companion App

A comprehensive Flutter health companion app with emergency features, medication reminders, and location-based services.

## Features

### 🚨 Emergency Features
- **Emergency Contacts**: Save and manage emergency contact numbers
- **Emergency Alert**: One-tap emergency button that calls emergency contact and sends location via SMS
- **Location Sharing**: Automatic GPS location sharing with emergency contacts

### 💊 Medication Management
- **Medication Reminders**: Set daily medication reminders with multiple times
- **Voice Notifications**: Text-to-speech reminders with medication details
- **Adherence Tracking**: Track medication intake and maintain streaks
- **Flexible Scheduling**: Choose days of week and multiple reminder times

### 📍 Location-Based Services
- **Nearby Services**: Find hospitals, pharmacies, grocery stores, and police stations
- **Google Maps Integration**: Real-time location services using Google Maps API
- **Directions**: One-tap directions to any location
- **Contact Integration**: Call locations directly from the app

### 👤 User Management
- **Local Authentication**: Secure login and registration system
- **Profile Management**: User profile with registration tracking
- **Local Database**: SQLite database for data persistence

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Google Cloud Console account

### 2. Google Maps API Setup

#### Step 1: Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Places API
   - Geocoding API

#### Step 2: Create API Keys
1. Go to "Credentials" in Google Cloud Console
2. Create API Key for Android
3. Restrict the key to your app's package name
4. Copy the API key

#### Step 3: Configure API Keys
1. Open `lib/config/app_config.dart`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your Maps API key
3. Replace `YOUR_GOOGLE_PLACES_API_KEY_HERE` with your Places API key
4. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_ACTUAL_API_KEY_HERE" />
   ```

### 3. Installation

#### Step 1: Clone Repository
```bash
git clone <repository-url>
cd jeevaan
```

#### Step 2: Install Dependencies
```bash
flutter pub get
```

#### Step 3: Generate App Icons
```bash
flutter pub run flutter_launcher_icons:main
```

#### Step 4: Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── config/
│   └── app_config.dart          # API keys and configuration
├── database/
│   └── database_helper.dart     # SQLite database operations
├── models/
│   ├── user.dart               # User data model
│   ├── emergency_contact.dart  # Emergency contact model
│   ├── medication.dart         # Medication model
│   └── nearby_location.dart    # Location service model
├── screens/
│   ├── splash_screen.dart      # App splash screen
│   ├── login_page.dart         # User login
│   ├── signup_page.dart        # User registration
│   ├── main_navigation.dart   # Main app navigation
│   ├── homepage.dart           # Home dashboard
│   ├── medication_page.dart    # Today's medications
│   ├── medication_management_page.dart # Medication management
│   ├── services_page.dart      # Services overview
│   ├── profile_page.dart       # User profile
│   ├── emergency_help_page.dart # Emergency features
│   ├── emergency_contact_page.dart # Emergency contact management
│   ├── nearby_locations_page.dart # Location services
│   └── database_test_page.dart # Database testing
├── services/
│   ├── auth_service.dart       # Authentication service
│   ├── location_service.dart   # GPS location service
│   ├── sms_service.dart        # SMS and phone call service
│   ├── medication_reminder_service.dart # Medication notifications
│   └── nearby_locations_service.dart # Google Places API service
└── main.dart                   # App entry point
```

## Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `sqflite`: SQLite database
- `path`: File path utilities

### Location & Maps
- `geolocator`: GPS location services
- `google_maps_flutter`: Google Maps integration
- `google_places_flutter`: Google Places API
- `http`: HTTP requests

### Notifications & Voice
- `flutter_local_notifications`: Local notifications
- `timezone`: Timezone handling
- `flutter_tts`: Text-to-speech

### UI & Utilities
- `url_launcher`: Launch external URLs
- `permission_handler`: Runtime permissions
- `flutter_launcher_icons`: App icon generation

## Permissions

The app requires the following Android permissions:

### Location Permissions
- `ACCESS_FINE_LOCATION`: Precise location access
- `ACCESS_COARSE_LOCATION`: Approximate location access
- `ACCESS_BACKGROUND_LOCATION`: Background location access

### Communication Permissions
- `CALL_PHONE`: Make phone calls
- `INTERNET`: Network access for API calls
- `ACCESS_NETWORK_STATE`: Network state monitoring

### Notification Permissions
- `RECEIVE_BOOT_COMPLETED`: Restart notifications after reboot
- `VIBRATE`: Notification vibration
- `WAKE_LOCK`: Keep device awake for notifications
- `USE_FULL_SCREEN_INTENT`: Full-screen notifications

## Usage

### Emergency Features
1. **Add Emergency Contacts**: Go to Emergency Contacts page
2. **Set Primary Contact**: Mark one contact as primary
3. **Emergency Alert**: Tap the red emergency button to call and send location

### Medication Management
1. **Add Medications**: Go to Medication Management
2. **Set Reminders**: Choose times and days
3. **Track Intake**: Mark medications as taken
4. **View Streaks**: Monitor adherence streaks

### Location Services
1. **Find Services**: Browse by category (Hospitals, Pharmacies, etc.)
2. **Search Places**: Use search bar for specific locations
3. **Get Directions**: Tap "Directions" button
4. **Call Locations**: Tap "Call" button if phone number available

## Troubleshooting

### Common Issues

#### 1. API Key Errors
- Ensure API keys are correctly configured
- Check API restrictions in Google Cloud Console
- Verify package name matches in API key restrictions

#### 2. Location Permission Issues
- Grant location permissions when prompted
- Check device location settings
- Ensure GPS is enabled

#### 3. Notification Issues
- Grant notification permissions
- Check device notification settings
- Ensure app is not battery optimized

#### 4. Database Issues
- Clear app data and reinstall
- Check database file permissions
- Verify SQLite dependencies

### Debug Mode
Enable debug logging by setting `debugPrint` in `main.dart`:
```dart
debugPrint = (String? message, {int? wrapWidth}) {
  print('DEBUG: $message');
};
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the Flutter documentation

## Future Enhancements

- [ ] Appointment scheduling
- [ ] Health data tracking
- [ ] Telemedicine integration
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Widget support
- [ ] Cloud backup
- [ ] Family member management