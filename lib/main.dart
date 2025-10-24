import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/medication_reminder_service.dart';
import 'services/dummy_data_service.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize authentication service
  await AuthService.initialize();
  
  // Initialize language service
  final languageService = LanguageService();
  await languageService.initialize();
  
  // Initialize medication reminder service
  await MedicationReminderService.initialize();
  
  // Reset database to ensure all tables are created
  final dbHelper = DatabaseHelper();
  await dbHelper.resetDatabase();
  
  // Add sample users if none exist
  await DummyDataService.addDummyUsers();
  
  // Add dummy doctors if none exist
  await DummyDataService.addDummyDoctors();
  
  // Add dummy medicines if none exist
  await DummyDataService.addDummyMedicines();
  
  // Add sample orders if none exist
  await DummyDataService.addDummyOrders();
  
  runApp(MyApp(languageService: languageService));
}

class MyApp extends StatelessWidget {
  final LanguageService languageService;
  
  const MyApp({
    super.key,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageService>(
      create: (context) => languageService,
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Jeevaan',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
              Locale('kn', ''),
              Locale('te', ''),
            ],
            locale: Locale(languageService.currentLanguage.code),
          );
        },
      ),
    );
  }
}
