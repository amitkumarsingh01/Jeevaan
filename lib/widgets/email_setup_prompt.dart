import 'package:flutter/material.dart';
import '../screens/edit_profile_page.dart';
import '../services/email_service.dart';

class EmailSetupPrompt {
  /// Show a dialog prompting user to set up email
  static Future<void> showEmailSetupDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.orange),
            SizedBox(width: 8),
            Text('Email Not Configured'),
          ],
        ),
        content: const Text(
          'To receive email reminders for medications and appointments, please set up your email address in your profile.\n\nWould you like to set it up now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Set Up Email'),
          ),
        ],
      ),
    );
  }
  
  /// Check and prompt if email is not configured
  static Future<bool> checkAndPromptEmail(BuildContext context) async {
    final isConfigured = await EmailService.isEmailConfigured();
    
    if (!isConfigured) {
      await showEmailSetupDialog(context);
      // Check again after user might have set it up
      return await EmailService.isEmailConfigured();
    }
    
    return true;
  }
}

