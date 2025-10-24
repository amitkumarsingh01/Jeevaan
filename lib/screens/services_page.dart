import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import 'emergency_help_page.dart';
import 'appointment_page.dart';
import 'nearby_locations_page.dart';
import 'medicine_catalog_page.dart';
import 'my_orders_page.dart';
import 'settings_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageService.translate('services')),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Services Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 60,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageService.translate('healthcare_services'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageService.translate('services_description'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Emergency Services
            _buildServiceSection(
              languageService,
              languageService.translate('emergency_services'),
              Icons.emergency,
              Colors.red,
              [
                _buildServiceCard(
                  context,
                  languageService,
                  Icons.emergency,
                  languageService.translate('emergency_help'),
                  languageService.translate('emergency_help_desc'),
                  Colors.red,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmergencyHelpPage()),
                  ),
                ),
                _buildServiceCard(
                  context,
                  languageService,
                  Icons.location_on,
                  languageService.translate('nearby_locations'),
                  languageService.translate('nearby_locations_desc'),
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NearbyLocationsPage()),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Medical Services
            _buildServiceSection(
              languageService,
              languageService.translate('medical_services'),
              Icons.medical_services,
              Colors.green,
              [
                _buildServiceCard(
                  context,
                  languageService,
                  Icons.calendar_today,
                  languageService.translate('appointments'),
                  languageService.translate('appointments_desc'),
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentPage()),
                  ),
                ),
                _buildServiceCard(
                  context,
                  languageService,
                  Icons.medication,
                  languageService.translate('medicine_catalog'),
                  languageService.translate('medicine_catalog_desc'),
                  Colors.teal,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MedicineCatalogPage()),
                  ),
                ),
                _buildServiceCard(
                  context,
                  languageService,
                  Icons.shopping_bag,
                  languageService.translate('my_orders'),
                  languageService.translate('my_orders_desc'),
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Settings & Preferences
            _buildServiceSection(
              languageService,
              languageService.translate('settings_preferences'),
              Icons.settings,
              Colors.grey,
              [
                _buildServiceCard(
                  context,
                  languageService,
                  Icons.settings,
                  languageService.translate('settings'),
                  languageService.translate('settings_desc'),
                  Colors.grey,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSection(
    LanguageService languageService,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    LanguageService languageService,
    IconData icon,
    String title,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
