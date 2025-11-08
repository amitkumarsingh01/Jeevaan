import 'package:flutter/material.dart';
import 'package:jeevaan/screens/medication_management_page.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'screens/medication_page.dart';
import 'screens/services_page.dart';
import 'screens/enhanced_profile_page.dart';
import 'screens/emergency_help_page.dart';
import 'screens/appointment_page.dart';
import 'screens/nearby_locations_page.dart';
import 'screens/my_orders_page.dart';
import 'screens/settings_page.dart';
import 'screens/login_page.dart';
import 'screens/emergency_contact_page.dart';
import 'screens/medicine_catalog_page.dart';
import 'screens/ChatScreen.dart';
import 'screens/health_news_page.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'services/voice_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final VoiceService _voiceService = VoiceService();
  bool _isVoiceCommandActive = false;

  final List<Widget> _pages = [
    const HomePage(),
    const MedicationPage(),
    const ChatScreen(),
    const ServicesPage(),
    const EnhancedProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    await _voiceService.initialize();
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    super.dispose();
  }

  void _handleVoiceCommand(String command) {
    final action = VoiceService.processNavigationCommand(command);
    
    if (action == null) return;

    switch (action) {
      case 'home':
        setState(() {
          _currentIndex = 0;
        });
        break;
      case 'medications':
        setState(() {
          _currentIndex = 1;
        });
        break;
      case 'chat':
        setState(() {
          _currentIndex = 2;
        });
        break;
      case 'services':
        setState(() {
          _currentIndex = 3;
        });
        break;
      case 'profile':
        setState(() {
          _currentIndex = 4;
        });
        break;
      case 'emergency':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmergencyHelpPage()),
        );
        break;
      case 'appointments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentPage()),
        );
        break;
      case 'locations':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NearbyLocationsPage()),
        );
        break;
      case 'orders':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyOrdersPage()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      case 'news':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HealthNewsPage()),
        );
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigated to: $action'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(languageService)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceCommandActive ? Icons.mic : Icons.mic_none,
              color: _isVoiceCommandActive ? Colors.red : Colors.white,
            ),
            tooltip: 'Voice Navigation',
            onPressed: () async {
              if (!_isVoiceCommandActive) {
                setState(() {
                  _isVoiceCommandActive = true;
                });
                await _voiceService.startListening(
                  onResult: (command) {
                    setState(() {
                      _isVoiceCommandActive = false;
                    });
                    _handleVoiceCommand(command);
                  },
                  onError: () {
                    setState(() {
                      _isVoiceCommandActive = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice recognition error. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                );
              } else {
                await _voiceService.stopListening();
                setState(() {
                  _isVoiceCommandActive = false;
                });
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[600],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Jeevaan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Your Health Companion',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.emergency, color: Colors.red),
              title: Text(languageService.translate('emergency_help')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyHelpPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts, color: Colors.red),
              title: Text(languageService.translate('emergency_contact')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyContactPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(languageService.translate('appointments')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppointmentPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(languageService.translate('nearby_locations')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NearbyLocationsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: Text(languageService.translate('medicine_catalog')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicineCatalogPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(languageService.translate('reminders')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicationManagementPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text(languageService.translate('my_orders')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('Health News'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HealthNewsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(languageService.translate('language')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.notifications),
            //   title: Text(languageService.translate('notifications')),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const NotificationsPage()),
            //     );
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.settings),
            //   title: Text(languageService.translate('settings')),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const SettingsPage()),
            //     );
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.storage),
            //   title: const Text('Database Test'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const DatabaseTestPage()),
            //     );
            //   },
            // ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                languageService.translate('logout'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: languageService.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medication),
            label: languageService.translate('medications'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: languageService.translate('chat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medical_services),
            label: languageService.translate('services'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: languageService.translate('profile'),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(LanguageService languageService) {
    switch (_currentIndex) {
      case 0:
        return languageService.translate('home');
      case 1:
        return languageService.translate('medications');
      case 2:
        return languageService.translate('healthcare_assistant');
      case 3:
        return languageService.translate('services');
      case 4:
        return languageService.translate('profile');
      default:
        return languageService.translate('app_name');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
