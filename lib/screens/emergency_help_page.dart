import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../database/database_helper.dart';
import '../services/sms_service.dart';
import '../services/voice_service.dart';
import '../services/notification_service.dart';
import 'emergency_contact_page.dart';

class EmergencyHelpPage extends StatefulWidget {
  const EmergencyHelpPage({super.key});

  @override
  State<EmergencyHelpPage> createState() => _EmergencyHelpPageState();
}

class _EmergencyHelpPageState extends State<EmergencyHelpPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  EmergencyContact? _primaryContact;
  final VoiceService _voiceService = VoiceService();
  bool _isVoiceCommandActive = false;

  @override
  void initState() {
    super.initState();
    _loadPrimaryContact();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    await _voiceService.initialize();
    // Start continuous listening for emergency commands
    _startEmergencyVoiceListener();
  }

  void _startEmergencyVoiceListener() {
    _voiceService.startListening(
      onResult: (command) {
        // Check for SMS command first (more specific)
        if (VoiceService.isEmergencySmsCommand(command)) {
          _sendEmergencySms();
        } 
        // Then check for call command
        else if (VoiceService.isEmergencyCallCommand(command)) {
          _makeEmergencyCall();
        }
        // Continue listening for emergency commands
        if (mounted) {
          _startEmergencyVoiceListener();
        }
      },
      onError: () {
        // Retry after error
        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _startEmergencyVoiceListener();
            }
          });
        }
      },
    );
    setState(() {
      _isVoiceCommandActive = true;
    });
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    super.dispose();
  }

  Future<void> _loadPrimaryContact() async {
    final contact = await _dbHelper.getPrimaryEmergencyContact();
    setState(() {
      _primaryContact = contact;
    });
  }

  Future<void> _makeEmergencyCall() async {
    if (_primaryContact == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No emergency contact set. Please add one first.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Initiating emergency call...'),
          ],
        ),
      ),
    );

    try {
      // Make call only
      bool callInitiated = await SmsService.makeEmergencyCall(_primaryContact!.phoneNumber);
      
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        if (callInitiated) {
          // Send notification and email
          await NotificationService.notifyEmergencyAlert(
            contactName: _primaryContact!.name,
            contactPhone: _primaryContact!.phoneNumber,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency call initiated!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initiate call. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error initiating emergency call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmergencySms() async {
    if (_primaryContact == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No emergency contact set. Please add one first.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Sending emergency SMS...'),
          ],
        ),
      ),
    );

    try {
      // Send SMS only
      bool smsSent = await SmsService.sendEmergencySmsOnly(_primaryContact!.phoneNumber);
      
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        if (smsSent) {
          // Send notification and email
          await NotificationService.notifyEmergencyAlert(
            contactName: _primaryContact!.name,
            contactPhone: _primaryContact!.phoneNumber,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency SMS sent with location!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send SMS. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error sending emergency SMS'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Help'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceCommandActive ? Icons.mic : Icons.mic_none,
              color: _isVoiceCommandActive ? Colors.yellow : Colors.white,
            ),
            tooltip: _isVoiceCommandActive 
                ? 'Voice Active - Say "Call" or "Send SMS"'
                : 'Activate Voice Commands',
            onPressed: () {
              if (_isVoiceCommandActive) {
                _voiceService.stopListening();
                setState(() {
                  _isVoiceCommandActive = false;
                });
              } else {
                _startEmergencyVoiceListener();
              }
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyContactPage(),
                ),
              ).then((_) => _loadPrimaryContact());
            },
            icon: const Icon(Icons.contacts),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red[50]!,
              Colors.red[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emergency Icon
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emergency,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Emergency Text
                Text(
                  'EMERGENCY',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Choose your emergency action below',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Primary Contact Info
                if (_primaryContact != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Emergency Contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _primaryContact!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _primaryContact!.phoneNumber,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _primaryContact!.relationship,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.orange[600],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Emergency Contact Set',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please add an emergency contact first',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
                
                // Voice Command Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.yellow[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mic,
                        color: Colors.yellow[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isVoiceCommandActive
                              ? 'Voice active! Say "Call" or "Phone" to call, "Send SMS" or "Text" to send message'
                              : 'Tap microphone icon to activate voice commands',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.yellow[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Emergency Buttons
                if (_primaryContact != null) ...[
                  // Call Button
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: _makeEmergencyCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'CALL EMERGENCY CONTACT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // SMS Button
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: _sendEmergencySms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'SEND LOCATION VIA SMS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // No Contact Button
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'NO CONTACT SET',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                
                // Manage Contacts Button
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyContactPage(),
                      ),
                    ).then((_) => _loadPrimaryContact());
                  },
                  icon: const Icon(Icons.contacts),
                  label: const Text('Manage Emergency Contacts'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
