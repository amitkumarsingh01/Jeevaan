import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  SupportedLanguage _currentLanguage = SupportedLanguage.english;
  SharedPreferences? _prefs;

  SupportedLanguage get currentLanguage => _currentLanguage;

  // Translation maps for each language
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Common
      'app_name': 'Jeevaan',
      'welcome': 'Welcome',
      'login': 'Login',
      'signup': 'Sign Up',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'phone': 'Phone',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'settings': 'Settings',
      'language': 'Language',
      'remember_me': 'Remember Me',
      
      // Navigation
      'home': 'Home',
      'medications': 'Medications',
      'reminders': 'Reminders',
      'services': 'Services',
      'profile': 'Profile',
      'emergency_help': 'Emergency Help',
      'appointments': 'Appointments',
      'nearby_locations': 'Nearby Locations',
      'my_orders': 'My Orders',
      'notifications': 'Notifications',
      'medicine_catalog': 'Medicine Catalog',
      
      // Emergency
      'emergency_contact': 'Emergency Contact',
      'emergency': 'EMERGENCY',
      'emergency_alert': 'Emergency Alert',
      'send_sms_call': 'SEND SMS & CALL',
      'no_contact_set': 'NO CONTACT SET',
      'primary_emergency_contact': 'Primary Emergency Contact',
      'manage_emergency_contacts': 'Manage Emergency Contacts',
      'emergency_sms_sent': 'Emergency SMS sent and call initiated!',
      'emergency_call_initiated': 'Emergency call initiated! SMS may not have been sent.',
      
      // Medications
      'medication_reminders': 'Medication Reminders',
      'add_medication': 'Add Medication',
      'medication_name': 'Medication Name',
      'dosage': 'Dosage',
      'frequency': 'Frequency',
      'time': 'Time',
      'instructions': 'Instructions',
      'take_medication': 'Take Medication',
      'medication_taken': 'Medication Taken',
      
      // Appointments
      'book_appointment': 'Book Appointment',
      'doctor_name': 'Doctor Name',
      'appointment_date': 'Appointment Date',
      'appointment_time': 'Appointment Time',
      'appointment_type': 'Appointment Type',
      'upcoming_appointments': 'Upcoming Appointments',
      'past_appointments': 'Past Appointments',
      
      // Medicine Catalog
      'add_to_cart': 'Add to Cart',
      'cart': 'Cart',
      'checkout': 'Checkout',
      'order_placed': 'Order Placed',
      'order_history': 'Order History',
      
      // Settings
      'change_language': 'Change Language',
      'select_language': 'Select Language',
      
      // Profile
      'no_profile': 'No Profile Found',
      'create_profile': 'Create Profile',
      'create_profile_message': 'Create your profile to get started with personalized healthcare services.',
      'edit_profile': 'Edit Profile',
      'personal_info': 'Personal Information',
      'medical_info': 'Medical Information',
      'preferences': 'Preferences',
      'blood_group': 'Blood Group',
      'medical_conditions': 'Medical Conditions',
      'allergies': 'Allergies',
      'relation': 'Relation',
      'none': 'None',
      'name_required': 'Name is required',
      'age_required': 'Age is required',
      'age_invalid': 'Please enter a valid age',
      'phone_required': 'Phone number is required',
      'email_required': 'Email is required',
      'email_invalid': 'Please enter a valid email',
      'address_required': 'Address is required',
      'emergency_name_required': 'Emergency contact name is required',
      'emergency_phone_required': 'Emergency contact phone is required',
      'relation_required': 'Emergency contact relation is required',
      
      // Home Page
      'welcome_message': 'Your health companion for a better tomorrow',
      'quick_actions': 'Quick Actions',
      'health_overview': 'Health Overview',
      'medications_today': 'Medications Today',
      'health_score': 'Health Score',
      'health_tips': 'Health Tips',
      'tip_1': 'Take your medications on time',
      'tip_2': 'Stay hydrated throughout the day',
      'tip_3': 'Get regular exercise',
      'tip_4': 'Maintain a balanced diet',
      'close': 'Close',
      
      // Services Page
      'healthcare_services': 'Healthcare Services',
      'services_description': 'Comprehensive healthcare services at your fingertips',
      'emergency_services': 'Emergency Services',
      'medical_services': 'Medical Services',
      'settings_preferences': 'Settings & Preferences',
      'emergency_help_desc': 'Get immediate help in emergency situations',
      'nearby_locations_desc': 'Find nearby hospitals, pharmacies, and more',
      'appointments_desc': 'Book and manage your doctor appointments',
      'medicine_catalog_desc': 'Browse and order medicines online',
      'my_orders_desc': 'Track your medicine orders and delivery',
      'settings_desc': 'Customize your app settings and preferences',
      
      // Chat Screen
      'healthcare_assistant': 'Healthcare Assistant',
      'chat': 'Chat',
      'chat_welcome_message': 'Ask me anything about health, medications, or medical advice',
      'chat_hint': 'Ask about health, medications, or medical advice...',
      
      // Profile Page
      'profile_information': 'Profile Information',
      'additional_info': 'Additional Information',
      'member_since': 'Member Since',
      'not_set': 'Not Set',
      'edit_profile_coming_soon': 'Edit profile feature coming soon!',
      'welcome_to_profile': 'Welcome to Profile Page',
      'profile_coming_soon': 'Enhanced profile features coming soon',
    },
    
    'hi': {
      // Common
      'app_name': 'जीवान',
      'welcome': 'स्वागत है',
      'login': 'लॉगिन',
      'signup': 'साइन अप',
      'logout': 'लॉग आउट',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'name': 'नाम',
      'phone': 'फोन',
      'save': 'सेव',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'add': 'जोड़ें',
      'search': 'खोजें',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
      'remember_me': 'मुझे याद रखें',
      
      // Navigation
      'home': 'होम',
      'medications': 'दवाएं',
      'reminders': 'अनुस्मारक',
      'services': 'सेवाएं',
      'profile': 'प्रोफाइल',
      'emergency_help': 'आपातकालीन सहायता',
      'appointments': 'अपॉइंटमेंट',
      'nearby_locations': 'पास के स्थान',
      'my_orders': 'मेरे ऑर्डर',
      'notifications': 'सूचनाएं',
      'medicine_catalog': 'दवा कैटलॉग',
      
      // Emergency
      'emergency_contact': 'आपातकालीन संपर्क',
      'emergency': 'आपातकाल',
      'emergency_alert': 'आपातकालीन अलर्ट',
      'send_sms_call': 'एसएमएस भेजें और कॉल करें',
      'no_contact_set': 'कोई संपर्क सेट नहीं',
      'primary_emergency_contact': 'प्राथमिक आपातकालीन संपर्क',
      'manage_emergency_contacts': 'आपातकालीन संपर्क प्रबंधित करें',
      'emergency_sms_sent': 'आपातकालीन एसएमएस भेजा गया और कॉल शुरू की गई!',
      'emergency_call_initiated': 'आपातकालीन कॉल शुरू की गई! एसएमएस नहीं भेजा गया हो सकता है।',
      
      // Medications
      'medication_reminders': 'दवा अनुस्मारक',
      'add_medication': 'दवा जोड़ें',
      'medication_name': 'दवा का नाम',
      'dosage': 'खुराक',
      'frequency': 'आवृत्ति',
      'time': 'समय',
      'instructions': 'निर्देश',
      'take_medication': 'दवा लें',
      'medication_taken': 'दवा ली गई',
      
      // Appointments
      'book_appointment': 'अपॉइंटमेंट बुक करें',
      'doctor_name': 'डॉक्टर का नाम',
      'appointment_date': 'अपॉइंटमेंट की तारीख',
      'appointment_time': 'अपॉइंटमेंट का समय',
      'appointment_type': 'अपॉइंटमेंट का प्रकार',
      'upcoming_appointments': 'आगामी अपॉइंटमेंट',
      'past_appointments': 'पिछले अपॉइंटमेंट',
      
      // Medicine Catalog
      'add_to_cart': 'कार्ट में जोड़ें',
      'cart': 'कार्ट',
      'checkout': 'चेकआउट',
      'order_placed': 'ऑर्डर दिया गया',
      'order_history': 'ऑर्डर इतिहास',
      
      // Settings
      'change_language': 'भाषा बदलें',
      'select_language': 'भाषा चुनें',
      
      // Profile
      'no_profile': 'कोई प्रोफाइल नहीं मिली',
      'create_profile': 'प्रोफाइल बनाएं',
      'create_profile_message': 'व्यक्तिगत स्वास्थ्य सेवाओं के साथ शुरुआत करने के लिए अपना प्रोफाइल बनाएं।',
      'edit_profile': 'प्रोफाइल संपादित करें',
      'personal_info': 'व्यक्तिगत जानकारी',
      'medical_info': 'चिकित्सा जानकारी',
      'preferences': 'प्राथमिकताएं',
      'blood_group': 'रक्त समूह',
      'medical_conditions': 'चिकित्सा स्थितियां',
      'allergies': 'एलर्जी',
      'relation': 'रिश्ता',
      'none': 'कोई नहीं',
      'name_required': 'नाम आवश्यक है',
      'age_required': 'आयु आवश्यक है',
      'age_invalid': 'कृपया वैध आयु दर्ज करें',
      'phone_required': 'फोन नंबर आवश्यक है',
      'email_required': 'ईमेल आवश्यक है',
      'email_invalid': 'कृपया वैध ईमेल दर्ज करें',
      'address_required': 'पता आवश्यक है',
      'emergency_name_required': 'आपातकालीन संपर्क नाम आवश्यक है',
      'emergency_phone_required': 'आपातकालीन संपर्क फोन आवश्यक है',
      'relation_required': 'आपातकालीन संपर्क रिश्ता आवश्यक है',
      
      // Home Page
      'welcome_message': 'बेहतर कल के लिए आपका स्वास्थ्य साथी',
      'quick_actions': 'त्वरित कार्य',
      'health_overview': 'स्वास्थ्य अवलोकन',
      'medications_today': 'आज की दवाएं',
      'health_score': 'स्वास्थ्य स्कोर',
      'health_tips': 'स्वास्थ्य सुझाव',
      'tip_1': 'समय पर अपनी दवाएं लें',
      'tip_2': 'दिन भर हाइड्रेटेड रहें',
      'tip_3': 'नियमित व्यायाम करें',
      'tip_4': 'संतुलित आहार बनाए रखें',
      'close': 'बंद करें',
      
      // Services Page
      'healthcare_services': 'स्वास्थ्य सेवाएं',
      'services_description': 'आपकी उंगलियों पर व्यापक स्वास्थ्य सेवाएं',
      'emergency_services': 'आपातकालीन सेवाएं',
      'medical_services': 'चिकित्सा सेवाएं',
      'settings_preferences': 'सेटिंग्स और प्राथमिकताएं',
      'emergency_help_desc': 'आपातकालीन स्थितियों में तत्काल सहायता प्राप्त करें',
      'nearby_locations_desc': 'पास के अस्पताल, फार्मेसी और अधिक खोजें',
      'appointments_desc': 'अपने डॉक्टर के अपॉइंटमेंट बुक और प्रबंधित करें',
      'medicine_catalog_desc': 'ऑनलाइन दवाएं ब्राउज़ और ऑर्डर करें',
      'my_orders_desc': 'अपने दवा ऑर्डर और डिलीवरी को ट्रैक करें',
      'settings_desc': 'अपनी ऐप सेटिंग्स और प्राथमिकताओं को कस्टमाइज़ करें',
      
      // Chat Screen
      'healthcare_assistant': 'स्वास्थ्य सहायक',
      'chat': 'चैट',
      'chat_welcome_message': 'स्वास्थ्य, दवाओं या चिकित्सा सलाह के बारे में कुछ भी पूछें',
      'chat_hint': 'स्वास्थ्य, दवाओं या चिकित्सा सलाह के बारे में पूछें...',
      
      // Profile Page
      'profile_information': 'प्रोफाइल जानकारी',
      'additional_info': 'अतिरिक्त जानकारी',
      'member_since': 'सदस्य बने',
      'not_set': 'सेट नहीं',
      'edit_profile_coming_soon': 'प्रोफाइल संपादन सुविधा जल्द आ रही है!',
      'welcome_to_profile': 'प्रोफाइल पेज में आपका स्वागत है',
      'profile_coming_soon': 'बेहतर प्रोफाइल सुविधाएं जल्द आ रही हैं',
    },
    
    'kn': {
      // Common
      'app_name': 'ಜೀವಾನ್',
      'welcome': 'ಸ್ವಾಗತ',
      'login': 'ಲಾಗಿನ್',
      'signup': 'ಸೈನ್ ಅಪ್',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'email': 'ಇಮೇಲ್',
      'password': 'ಪಾಸ್ವರ್ಡ್',
      'name': 'ಹೆಸರು',
      'phone': 'ಫೋನ್',
      'save': 'ಉಳಿಸಿ',
      'cancel': 'ರದ್ದುಗೊಳಿಸಿ',
      'delete': 'ಅಳಿಸಿ',
      'edit': 'ಸಂಪಾದಿಸಿ',
      'add': 'ಸೇರಿಸಿ',
      'search': 'ಹುಡುಕಿ',
      'settings': 'ಸೆಟ್ಟಿಂಗ್ಸ್',
      'language': 'ಭಾಷೆ',
      'remember_me': 'ನನ್ನನ್ನು ನೆನಪಿಡಿ',
      
      // Navigation
      'home': 'ಮನೆ',
      'medications': 'ಔಷಧಿಗಳು',
      'reminders': 'ನೆನಪುಗಳು',
      'services': 'ಸೇವೆಗಳು',
      'profile': 'ಪ್ರೊಫೈಲ್',
      'emergency_help': 'ಅತ್ಯಾವಶ್ಯಕ ಸಹಾಯ',
      'appointments': 'ನಿಯಮಿತ ಸಮಯ',
      'nearby_locations': 'ಹತ್ತಿರದ ಸ್ಥಳಗಳು',
      'my_orders': 'ನನ್ನ ಆದೇಶಗಳು',
      'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
      'medicine_catalog': 'ಔಷಧಿ ಕ್ಯಾಟಲಾಗ್',
      
      // Emergency
      'emergency_contact': 'ಅತ್ಯಾವಶ್ಯಕ ಸಂಪರ್ಕ',
      'emergency': 'ಅತ್ಯಾವಶ್ಯಕ',
      'emergency_alert': 'ಅತ್ಯಾವಶ್ಯಕ ಎಚ್ಚರಿಕೆ',
      'send_sms_call': 'ಎಸ್ಎಂಎಸ್ ಕಳುಹಿಸಿ ಮತ್ತು ಕರೆ ಮಾಡಿ',
      'no_contact_set': 'ಸಂಪರ್ಕ ಹೊಂದಿಸಿಲ್ಲ',
      'primary_emergency_contact': 'ಪ್ರಾಥಮಿಕ ಅತ್ಯಾವಶ್ಯಕ ಸಂಪರ್ಕ',
      'manage_emergency_contacts': 'ಅತ್ಯಾವಶ್ಯಕ ಸಂಪರ್ಕಗಳನ್ನು ನಿರ್ವಹಿಸಿ',
      'emergency_sms_sent': 'ಅತ್ಯಾವಶ್ಯಕ ಎಸ್ಎಂಎಸ್ ಕಳುಹಿಸಲಾಗಿದೆ ಮತ್ತು ಕರೆ ಪ್ರಾರಂಭಿಸಲಾಗಿದೆ!',
      'emergency_call_initiated': 'ಅತ್ಯಾವಶ್ಯಕ ಕರೆ ಪ್ರಾರಂಭಿಸಲಾಗಿದೆ! ಎಸ್ಎಂಎಸ್ ಕಳುಹಿಸಲಾಗಿಲ್ಲ.',
      
      // Medications
      'medication_reminders': 'ಔಷಧಿ ನೆನಪುಗಳು',
      'add_medication': 'ಔಷಧಿ ಸೇರಿಸಿ',
      'medication_name': 'ಔಷಧಿಯ ಹೆಸರು',
      'dosage': 'ಮಾತ್ರೆ',
      'frequency': 'ಆವರ್ತನ',
      'time': 'ಸಮಯ',
      'instructions': 'ಸೂಚನೆಗಳು',
      'take_medication': 'ಔಷಧಿ ತೆಗೆದುಕೊಳ್ಳಿ',
      'medication_taken': 'ಔಷಧಿ ತೆಗೆದುಕೊಳ್ಳಲಾಗಿದೆ',
      
      // Appointments
      'book_appointment': 'ನಿಯಮಿತ ಸಮಯ ಬುಕ್ ಮಾಡಿ',
      'doctor_name': 'ವೈದ್ಯರ ಹೆಸರು',
      'appointment_date': 'ನಿಯಮಿತ ಸಮಯದ ದಿನಾಂಕ',
      'appointment_time': 'ನಿಯಮಿತ ಸಮಯದ ಸಮಯ',
      'appointment_type': 'ನಿಯಮಿತ ಸಮಯದ ಪ್ರಕಾರ',
      'upcoming_appointments': 'ಮುಂದಿನ ನಿಯಮಿತ ಸಮಯಗಳು',
      'past_appointments': 'ಹಿಂದಿನ ನಿಯಮಿತ ಸಮಯಗಳು',
      
      // Medicine Catalog
      'add_to_cart': 'ಕಾರ್ಟ್‌ಗೆ ಸೇರಿಸಿ',
      'cart': 'ಕಾರ್ಟ್',
      'checkout': 'ಚೆಕ್‌ಔಟ್',
      'order_placed': 'ಆದೇಶ ನೀಡಲಾಗಿದೆ',
      'order_history': 'ಆದೇಶ ಇತಿಹಾಸ',
      
      // Settings
      'change_language': 'ಭಾಷೆ ಬದಲಾಯಿಸಿ',
      'select_language': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
      
      // Profile
      'no_profile': 'ಪ್ರೊಫೈಲ್ ಕಂಡುಬಂದಿಲ್ಲ',
      'create_profile': 'ಪ್ರೊಫೈಲ್ ರಚಿಸಿ',
      'create_profile_message': 'ವೈಯಕ್ತಿಕ ಆರೋಗ್ಯ ಸೇವೆಗಳೊಂದಿಗೆ ಪ್ರಾರಂಭಿಸಲು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ರಚಿಸಿ.',
      'edit_profile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ',
      'personal_info': 'ವೈಯಕ್ತಿಕ ಮಾಹಿತಿ',
      'medical_info': 'ವೈದ್ಯಕೀಯ ಮಾಹಿತಿ',
      'preferences': 'ಆದ್ಯತೆಗಳು',
      'blood_group': 'ರಕ್ತ ಗುಂಪು',
      'medical_conditions': 'ವೈದ್ಯಕೀಯ ಸ್ಥಿತಿಗಳು',
      'allergies': 'ಅಲರ್ಜಿಗಳು',
      'relation': 'ಸಂಬಂಧ',
      'none': 'ಯಾವುದೂ ಇಲ್ಲ',
      'name_required': 'ಹೆಸರು ಅಗತ್ಯ',
      'age_required': 'ವಯಸ್ಸು ಅಗತ್ಯ',
      'age_invalid': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ವಯಸ್ಸನ್ನು ನಮೂದಿಸಿ',
      'phone_required': 'ಫೋನ್ ಸಂಖ್ಯೆ ಅಗತ್ಯ',
      'email_required': 'ಇಮೇಲ್ ಅಗತ್ಯ',
      'email_invalid': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಇಮೇಲ್ ನಮೂದಿಸಿ',
      'address_required': 'ವಿಳಾಸ ಅಗತ್ಯ',
      'emergency_name_required': 'ಅತ್ಯಾಹತ ಸಂಪರ್ಕ ಹೆಸರು ಅಗತ್ಯ',
      'emergency_phone_required': 'ಅತ್ಯಾಹತ ಸಂಪರ್ಕ ಫೋನ್ ಅಗತ್ಯ',
      'relation_required': 'ಅತ್ಯಾಹತ ಸಂಪರ್ಕ ಸಂಬಂಧ ಅಗತ್ಯ',
      
      // Home Page
      'welcome_message': 'ಉತ್ತಮ ನಾಳೆಗಾಗಿ ನಿಮ್ಮ ಆರೋಗ್ಯ ಸಂಗಾತಿ',
      'quick_actions': 'ತ್ವರಿತ ಕ್ರಿಯೆಗಳು',
      'health_overview': 'ಆರೋಗ್ಯ ಅವಲೋಕನ',
      'medications_today': 'ಇಂದಿನ ಔಷಧಿಗಳು',
      'health_score': 'ಆರೋಗ್ಯ ಸ್ಕೋರ್',
      'health_tips': 'ಆರೋಗ್ಯ ಸಲಹೆಗಳು',
      'tip_1': 'ಸಮಯಕ್ಕೆ ನಿಮ್ಮ ಔಷಧಿಗಳನ್ನು ತೆಗೆದುಕೊಳ್ಳಿ',
      'tip_2': 'ದಿನವಿಡೀ ಹೈಡ್ರೇಟೆಡ್ ಆಗಿರಿ',
      'tip_3': 'ನಿಯಮಿತ ವ್ಯಾಯಾಮ ಮಾಡಿ',
      'tip_4': 'ಸಮತೋಲಿತ ಆಹಾರವನ್ನು ನಿರ್ವಹಿಸಿ',
      'close': 'ಮುಚ್ಚಿ',
      
      // Services Page
      'healthcare_services': 'ಆರೋಗ್ಯ ಸೇವೆಗಳು',
      'services_description': 'ನಿಮ್ಮ ಬೆರಳ ತುದಿಗಳಲ್ಲಿ ಸಮಗ್ರ ಆರೋಗ್ಯ ಸೇವೆಗಳು',
      'emergency_services': 'ಅತ್ಯಾಹತ ಸೇವೆಗಳು',
      'medical_services': 'ವೈದ್ಯಕೀಯ ಸೇವೆಗಳು',
      'settings_preferences': 'ಸೆಟ್ಟಿಂಗ್ಸ್ ಮತ್ತು ಆದ್ಯತೆಗಳು',
      'emergency_help_desc': 'ಅತ್ಯಾಹತ ಸಂದರ್ಭಗಳಲ್ಲಿ ತಕ್ಷಣ ಸಹಾಯ ಪಡೆಯಿರಿ',
      'nearby_locations_desc': 'ಹತ್ತಿರದ ಆಸ್ಪತ್ರೆಗಳು, ಔಷಧಾಲಯಗಳು ಮತ್ತು ಹೆಚ್ಚು ಹುಡುಕಿ',
      'appointments_desc': 'ನಿಮ್ಮ ವೈದ್ಯರ ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್‌ಗಳನ್ನು ಬುಕ್ ಮಾಡಿ ಮತ್ತು ನಿರ್ವಹಿಸಿ',
      'medicine_catalog_desc': 'ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ಔಷಧಿಗಳನ್ನು ಬ್ರೌಸ್ ಮಾಡಿ ಮತ್ತು ಆರ್ಡರ್ ಮಾಡಿ',
      'my_orders_desc': 'ನಿಮ್ಮ ಔಷಧಿ ಆದೇಶಗಳು ಮತ್ತು ವಿತರಣೆಯನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಿ',
      'settings_desc': 'ನಿಮ್ಮ ಅಪ್ ಸೆಟ್ಟಿಂಗ್ಸ್ ಮತ್ತು ಆದ್ಯತೆಗಳನ್ನು ಕಸ್ಟಮೈಸ್ ಮಾಡಿ',
      
      // Chat Screen
      'healthcare_assistant': 'ಆರೋಗ್ಯ ಸಹಾಯಕ',
      'chat': 'ಚಾಟ್',
      'chat_welcome_message': 'ಆರೋಗ್ಯ, ಔಷಧಿಗಳು ಅಥವಾ ವೈದ್ಯಕೀಯ ಸಲಹೆಗಳ ಬಗ್ಗೆ ಯಾವುದಾದರೂ ಕೇಳಿ',
      'chat_hint': 'ಆರೋಗ್ಯ, ಔಷಧಿಗಳು ಅಥವಾ ವೈದ್ಯಕೀಯ ಸಲಹೆಗಳ ಬಗ್ಗೆ ಕೇಳಿ...',
      
      // Profile Page
      'profile_information': 'ಪ್ರೊಫೈಲ್ ಮಾಹಿತಿ',
      'additional_info': 'ಹೆಚ್ಚುವರಿ ಮಾಹಿತಿ',
      'member_since': 'ಸದಸ್ಯರಾದರು',
      'not_set': 'ಸೆಟ್ ಮಾಡಿಲ್ಲ',
      'edit_profile_coming_soon': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದನಾ ವೈಶಿಷ್ಟ್ಯ ಶೀಘ್ರದಲ್ಲೇ ಬರುತ್ತಿದೆ!',
      'welcome_to_profile': 'ಪ್ರೊಫೈಲ್ ಪುಟಕ್ಕೆ ಸ್ವಾಗತ',
      'profile_coming_soon': 'ಉನ್ನತ ಪ್ರೊಫೈಲ್ ವೈಶಿಷ್ಟ್ಯಗಳು ಶೀಘ್ರದಲ್ಲೇ ಬರುತ್ತಿವೆ',
    },
    
    'te': {
      // Common
      'app_name': 'జీవాన్',
      'welcome': 'స్వాగతం',
      'login': 'లాగిన్',
      'signup': 'సైన్ అప్',
      'logout': 'లాగ్ అవుట్',
      'email': 'ఇమెయిల్',
      'password': 'పాస్‌వర్డ్',
      'name': 'పేరు',
      'phone': 'ఫోన్',
      'save': 'సేవ్',
      'cancel': 'రద్దు చేయి',
      'delete': 'తొలగించు',
      'edit': 'సవరించు',
      'add': 'జోడించు',
      'search': 'వెతుకు',
      'settings': 'సెట్టింగ్‌లు',
      'language': 'భాష',
      'remember_me': 'నన్ను గుర్తుంచుకో',
      
      // Navigation
      'home': 'హోమ్',
      'medications': 'మందులు',
      'reminders': 'గుర్తుచేతనలు',
      'services': 'సేవలు',
      'profile': 'ప్రొఫైల్',
      'emergency_help': 'అత్యవసర సహాయం',
      'appointments': 'అపాయింట్‌మెంట్‌లు',
      'nearby_locations': 'సమీప ప్రదేశాలు',
      'my_orders': 'నా ఆర్డర్‌లు',
      'notifications': 'నోటిఫికేషన్‌లు',
      'medicine_catalog': 'మందుల క్యాటలాగ్',
      
      // Emergency
      'emergency_contact': 'అత్యవసర సంప్రదింపు',
      'emergency': 'అత్యవసర',
      'emergency_alert': 'అత్యవసర హెచ్చరిక',
      'send_sms_call': 'ఎస్‌ఎమ్‌ఎస్ పంపండి మరియు కాల్ చేయండి',
      'no_contact_set': 'సంప్రదింపు సెట్ చేయబడలేదు',
      'primary_emergency_contact': 'ప్రాథమిక అత్యవసర సంప్రదింపు',
      'manage_emergency_contacts': 'అత్యవసర సంప్రదింపులను నిర్వహించండి',
      'emergency_sms_sent': 'అత్యవసర ఎస్‌ఎమ్‌ఎస్ పంపబడింది మరియు కాల్ ప్రారంభించబడింది!',
      'emergency_call_initiated': 'అత్యవసర కాల్ ప్రారంభించబడింది! ఎస్‌ఎమ్‌ఎస్ పంపబడకపోవచ్చు.',
      
      // Medications
      'medication_reminders': 'మందుల గుర్తుచేతనలు',
      'add_medication': 'మందు జోడించండి',
      'medication_name': 'మందు పేరు',
      'dosage': 'మోతాదు',
      'frequency': 'పౌనఃపున్యం',
      'time': 'సమయం',
      'instructions': 'సూచనలు',
      'take_medication': 'మందు తీసుకోండి',
      'medication_taken': 'మందు తీసుకోబడింది',
      
      // Appointments
      'book_appointment': 'అపాయింట్‌మెంట్ బుక్ చేయండి',
      'doctor_name': 'డాక్టర్ పేరు',
      'appointment_date': 'అపాయింట్‌మెంట్ తేదీ',
      'appointment_time': 'అపాయింట్‌మెంట్ సమయం',
      'appointment_type': 'అపాయింట్‌మెంట్ రకం',
      'upcoming_appointments': 'రాబోయే అపాయింట్‌మెంట్‌లు',
      'past_appointments': 'గత అపాయింట్‌మెంట్‌లు',
      
      // Medicine Catalog
      'add_to_cart': 'కార్ట్‌కు జోడించండి',
      'cart': 'కార్ట్',
      'checkout': 'చెక్‌అవుట్',
      'order_placed': 'ఆర్డర్ ఇవ్వబడింది',
      'order_history': 'ఆర్డర్ చరిత్ర',
      
      // Settings
      'change_language': 'భాష మార్చండి',
      'select_language': 'భాష ఎంచుకోండి',
      
      // Profile
      'no_profile': 'ప్రొఫైల్ కనుగొనబడలేదు',
      'create_profile': 'ప్రొఫైల్ సృష్టించండి',
      'create_profile_message': 'వ్యక్తిగత ఆరోగ్య సేవలతో ప్రారంభించడానికి మీ ప్రొఫైల్‌ను సృష్టించండి.',
      'edit_profile': 'ప్రొఫైల్ సవరించండి',
      'personal_info': 'వ్యక్తిగత సమాచారం',
      'medical_info': 'వైద్య సమాచారం',
      'preferences': 'అభిరుచులు',
      'blood_group': 'రక్త సమూహం',
      'medical_conditions': 'వైద్య పరిస్థితులు',
      'allergies': 'అలెర్జీలు',
      'relation': 'సంబంధం',
      'none': 'ఏదీ లేదు',
      'name_required': 'పేరు అవసరం',
      'age_required': 'వయస్సు అవసరం',
      'age_invalid': 'దయచేసి చెల్లుబాటు అయ్యే వయస్సును నమోదు చేయండి',
      'phone_required': 'ఫోన్ నంబర్ అవసరం',
      'email_required': 'ఇమెయిల్ అవసరం',
      'email_invalid': 'దయచేసి చెల్లుబాటు అయ్యే ఇమెయిల్‌ను నమోదు చేయండి',
      'address_required': 'చిరునామా అవసరం',
      'emergency_name_required': 'అత్యవసర సంప్రదింపు పేరు అవసరం',
      'emergency_phone_required': 'అత్యవసర సంప్రదింపు ఫోన్ అవసరం',
      'relation_required': 'అత్యవసర సంప్రదింపు సంబంధం అవసరం',
      
      // Home Page
      'welcome_message': 'మెరుగైన రేపటి కోసం మీ ఆరోగ్య సహచరుడు',
      'quick_actions': 'త్వరిత చర్యలు',
      'health_overview': 'ఆరోగ్య అవలోకనం',
      'medications_today': 'ఈరోజు మందులు',
      'health_score': 'ఆరోగ్య స్కోర్',
      'health_tips': 'ఆరోగ్య చిట్కాలు',
      'tip_1': 'సమయానికి మీ మందులను తీసుకోండి',
      'tip_2': 'రోజంతా హైడ్రేటెడ్‌గా ఉండండి',
      'tip_3': 'క్రమమైన వ్యాయామం చేయండి',
      'tip_4': 'సమతుల్య ఆహారాన్ని నిర్వహించండి',
      'close': 'మూసివేయి',
      
      // Services Page
      'healthcare_services': 'ఆరోగ్య సేవలు',
      'services_description': 'మీ వేళ్ల చివర్లలో సమగ్ర ఆరోగ్య సేవలు',
      'emergency_services': 'అత్యవసర సేవలు',
      'medical_services': 'వైద్య సేవలు',
      'settings_preferences': 'సెట్టింగ్‌లు మరియు ప్రాధాన్యతలు',
      'emergency_help_desc': 'అత్యవసర పరిస్థితులలో వెంటనే సహాయం పొందండి',
      'nearby_locations_desc': 'సమీప ఆసుపత్రులు, మందుల దుకాణాలు మరియు మరిన్ని కనుగొనండి',
      'appointments_desc': 'మీ వైద్యుడి అపాయింట్‌మెంట్‌లను బుక్ చేసి నిర్వహించండి',
      'medicine_catalog_desc': 'ఆన్‌లైన్‌లో మందులను బ్రౌజ్ చేసి ఆర్డర్ చేయండి',
      'my_orders_desc': 'మీ మందుల ఆర్డర్‌లు మరియు డెలివరీని ట్రాక్ చేయండి',
      'settings_desc': 'మీ యాప్ సెట్టింగ్‌లు మరియు ప్రాధాన్యతలను కస్టమైజ్ చేయండి',
      
      // Chat Screen
      'healthcare_assistant': 'ఆరోగ్య సహాయకుడు',
      'chat': 'చాట్',
      'chat_welcome_message': 'ఆరోగ్యం, మందులు లేదా వైద్య సలహాల గురించి ఏదైనా అడగండి',
      'chat_hint': 'ఆరోగ్యం, మందులు లేదా వైద్య సలహాల గురించి అడగండి...',
      
      // Profile Page
      'profile_information': 'ప్రొఫైల్ సమాచారం',
      'additional_info': 'అదనపు సమాచారం',
      'member_since': 'సభ్యుడిగా చేరారు',
      'not_set': 'సెట్ చేయలేదు',
      'edit_profile_coming_soon': 'ప్రొఫైల్ సవరణ లక్షణం త్వరలో వస్తోంది!',
      'welcome_to_profile': 'ప్రొఫైల్ పేజీకి స్వాగతం',
      'profile_coming_soon': 'మెరుగైన ప్రొఫైల్ లక్షణాలు త్వరలో వస్తున్నాయి',
    },
  };

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = _prefs?.getString(_languageKey);
    if (savedLanguageCode != null) {
      _currentLanguage = SupportedLanguage.fromCode(savedLanguageCode);
    }
  }

  String translate(String key) {
    return _translations[_currentLanguage.code]?[key] ?? 
           _translations['en']?[key] ?? 
           key;
  }

  Future<void> changeLanguage(SupportedLanguage language) async {
    _currentLanguage = language;
    await _prefs?.setString(_languageKey, language.code);
    notifyListeners();
  }

  static String getTranslation(String key, SupportedLanguage language) {
    return _translations[language.code]?[key] ?? 
           _translations['en']?[key] ?? 
           key;
  }
}
