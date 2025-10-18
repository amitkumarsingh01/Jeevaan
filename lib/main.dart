import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/medication_reminder_service.dart';
import 'services/dummy_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize medication reminder service
  await MedicationReminderService.initialize();
  
  // Add dummy doctors if none exist
  await DummyDataService.addDummyDoctors();
  
  // Add dummy medicines if none exist
  await DummyDataService.addDummyMedicines();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeevaan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
