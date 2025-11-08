import 'package:flutter/material.dart';
import '../services/voice_service.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onResult;
  final Color? color;
  final double? size;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.color,
    this.size,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;
  bool _isAvailable = true; // Default to true so button shows immediately

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      // Initialize if not already initialized
      await _voiceService.initialize();
      final available = await _voiceService.checkAvailability();
      setState(() {
        _isAvailable = available;
      });
    } catch (e) {
      print('Error checking voice availability: $e');
      setState(() {
        _isAvailable = false;
      });
    }
  }

  Future<void> _startListening() async {
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice recognition not available. Please check microphone permissions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
    });

    await _voiceService.startListening(
      onResult: (text) {
        setState(() {
          _isListening = false;
        });
        widget.onResult(text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice input: $text'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onError: () {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice recognition error. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isAvailable ? (_) => _startListening() : null,
      onTapUp: _isAvailable ? (_) => _stopListening() : null,
      onTapCancel: _isAvailable ? () => _stopListening() : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isListening
              ? (widget.color ?? Colors.blue).withValues(alpha: 0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: _isListening
              ? (widget.color ?? Colors.blue)
              : (_isAvailable 
                  ? (widget.color ?? Colors.grey)
                  : Colors.grey[400]!),
          size: widget.size ?? 24,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    super.dispose();
  }
}

