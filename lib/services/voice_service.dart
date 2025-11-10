import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  stt.SpeechToText? _speech;
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastWords = '';
  Function(String)? _onResult;
  Function()? _onError;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    _speech = stt.SpeechToText();
    
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      return false;
    }

    // Check availability
    _isAvailable = await _speech!.initialize(
      onError: (error) {
        _isListening = false;
        _onError?.call();
        debugPrint('Speech recognition error: $error');
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
        debugPrint('Speech recognition status: $status');
      },
    );

    return _isAvailable;
  }

  /// Start listening for voice input
  Future<void> startListening({
    Function(String)? onResult,
    Function()? onError,
    String localeId = 'en_US',
  }) async {
    if (!_isAvailable || _isListening) {
      return;
    }

    _onResult = onResult;
    _onError = onError;

    try {
      await _speech!.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            _onResult?.call(_lastWords);
          }
        },
        localeId: localeId,
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      );
      _isListening = true;
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _onError?.call();
    }
  }

  /// Stop listening for voice input
  Future<void> stopListening() async {
    if (_isListening && _speech != null) {
      await _speech!.stop();
      _isListening = false;
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening && _speech != null) {
      await _speech!.cancel();
      _isListening = false;
    }
  }

  /// Check if speech recognition is available
  Future<bool> checkAvailability() async {
    if (_speech == null) {
      return await initialize();
    }
    return _isAvailable;
  }

  /// Get available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (_speech == null) {
      await initialize();
    }
    if (_speech == null) {
      return [];
    }
    return await _speech!.locales();
  }

  /// Process voice command for navigation
  static String? processNavigationCommand(String command) {
    final lowerCommand = command.toLowerCase().trim();
    
    // Navigation commands
    if (lowerCommand.contains('home') || lowerCommand.contains('go home')) {
      return 'home';
    } else if (lowerCommand.contains('medication') || lowerCommand.contains('medications')) {
      return 'medications';
    } else if (lowerCommand.contains('chat') || lowerCommand.contains('assistant')) {
      return 'chat';
    } else if (lowerCommand.contains('service') || lowerCommand.contains('services')) {
      return 'services';
    } else if (lowerCommand.contains('profile') || lowerCommand.contains('my profile')) {
      return 'profile';
    } else if (lowerCommand.contains('emergency') || lowerCommand.contains('sos') || lowerCommand.contains('help')) {
      return 'emergency';
    } else if (lowerCommand.contains('appointment') || lowerCommand.contains('appointments')) {
      return 'appointments';
    } else if (lowerCommand.contains('location') || lowerCommand.contains('locations')) {
      return 'locations';
    } else if (lowerCommand.contains('order') || lowerCommand.contains('orders')) {
      return 'orders';
    } else if (lowerCommand.contains('setting') || lowerCommand.contains('settings')) {
      return 'settings';
    } else if (lowerCommand.contains('news') || lowerCommand.contains('health news')) {
      return 'news';
    }
    
    return null;
  }

  /// Process voice command for Emergency SOS
  static bool isEmergencyCommand(String command) {
    final lowerCommand = command.toLowerCase().trim();
    return lowerCommand.contains('emergency') ||
           lowerCommand.contains('sos') ||
           lowerCommand.contains('help me') ||
           lowerCommand.contains('call emergency') ||
           lowerCommand.contains('emergency call');
  }

  /// Process voice command for Emergency Call
  static bool isEmergencyCallCommand(String command) {
    final lowerCommand = command.toLowerCase().trim();
    return lowerCommand.contains('call') ||
           lowerCommand.contains('phone') ||
           lowerCommand.contains('emergency call') ||
           lowerCommand.contains('call emergency') ||
           lowerCommand.contains('make a call') ||
           (isEmergencyCommand(command) && !isEmergencySmsCommand(command));
  }

  /// Process voice command for Emergency SMS
  static bool isEmergencySmsCommand(String command) {
    final lowerCommand = command.toLowerCase().trim();
    return lowerCommand.contains('send sms') ||
           lowerCommand.contains('send message') ||
           lowerCommand.contains('text') ||
           lowerCommand.contains('message') ||
           lowerCommand.contains('send text') ||
           lowerCommand.contains('sms') ||
           lowerCommand.contains('send location') ||
           lowerCommand.contains('text emergency') ||
           lowerCommand.contains('message emergency');
  }

  /// Process voice command for login actions
  static String? processLoginCommand(String command) {
    final lowerCommand = command.toLowerCase().trim();
    
    if (lowerCommand.contains('login') || lowerCommand.contains('sign in')) {
      return 'login';
    } else if (lowerCommand.contains('sign up') || lowerCommand.contains('register')) {
      return 'signup';
    }
    
    return null;
  }

  /// Dispose resources
  void dispose() {
    stopListening();
    _speech = null;
    _isAvailable = false;
    _onResult = null;
    _onError = null;
  }
}

