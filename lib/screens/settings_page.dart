import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../widgets/language_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.watch<LanguageService>().translate('language'),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LanguageSelector(
                  languageService: context.watch<LanguageService>(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Other Settings
            // Card(
            //   elevation: 4,
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           context.watch<LanguageService>().translate('language'),
            //           style: const TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         const SizedBox(height: 16),
                    
            //         // Notification Settings
            //         ListTile(
            //           leading: const Icon(Icons.notifications),
            //           title: Text(
            //             context.watch<LanguageService>().translate('notifications'),
            //           ),
            //           trailing: Switch(
            //             value: true,
            //             onChanged: (value) {
            //               // Handle notification settings
            //             },
            //           ),
            //         ),
                    
            //         // Theme Settings
            //         ListTile(
            //           leading: const Icon(Icons.palette),
            //           title: const Text('Theme'),
            //           trailing: const Icon(Icons.arrow_forward_ios),
            //           onTap: () {
            //             // Handle theme settings
            //           },
            //         ),
                    
            //         // About
            //         ListTile(
            //           leading: const Icon(Icons.info),
            //           title: const Text('About'),
            //           trailing: const Icon(Icons.arrow_forward_ios),
            //           onTap: () {
            //             // Handle about
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}