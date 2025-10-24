import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';


class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const JeevaanAI();
  }
}

class ChatMessage {
  final String role;
  final String text;
  final File? image;

  ChatMessage({required this.role, required this.text, this.image});
}

class JeevaanAI extends StatefulWidget {
  const JeevaanAI({super.key});

  @override
  State<JeevaanAI> createState() => _JeevaanAIState();
}

class _JeevaanAIState extends State<JeevaanAI> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  File? _selectedImage;
  bool _isProcessing = false;

  // TODO: Replace with your API key
  final String apiKey = "AIzaSyCxCvv8srO4-exD_x9MU8TXeYrYh5HYGsc";
  late GenerativeModel model;

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  void _initializeAI() {
    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  Future<String> _processImageAndText(String input, File? image) async {
    try {
      if (image != null) {
        final bytes = await image.readAsBytes();

        final prompt = input.isNotEmpty
            ? "You are a healthcare assistant named Jeevaan AI for old age people. Question: $input in less than 100 char. Don't use bold or *"
            : "You are a healthcare assistant named Jeevaan AI for old age people. in less than 100 char. Don't use bold or *";

        final content = [
          Content.text(prompt),
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', bytes)
          ])
        ];

        final response = await model.generateContent(content);
        return response.text ?? "No response generated";
      } else {
        if (input.isEmpty) {
          return "Please enter Details";
        }

        final prompt = "You are Jeevaan AI, a healthcare assistant. Please provide helpful medical information and health advice for: $input in less than 100 char. Don't use bold or *";
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);
        return response.text ?? "No response generated";
      }
    } catch (e) {
      return "Error processing request: ${e.toString()}";
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    final input = _textController.text.trim();

    if (input.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter text or select an image'))
      );
      return;
    }

    // Add user message
    setState(() {
      _isProcessing = true;
      _messages.insert(
        0,
        ChatMessage(
          role: 'YOU',
          text: input.isEmpty ? 'Image uploaded' : input,
          image: _selectedImage,
        ),
      );
    });

    // Process with AI
    try {
      final response = await _processImageAndText(input, _selectedImage);

      setState(() {
        _messages.insert(
          0,
        ChatMessage(
          role: 'Jeevaan AI',
          text: response,
        ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
        ChatMessage(
          role: 'Jeevaan AI',
          text: 'Error: ${e.toString()}',
        ),
        );
      });
    } finally {
      setState(() {
        _isProcessing = false;
        _textController.clear();
        _selectedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageService.translate('healthcare_assistant'),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Welcome banner
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   color: Theme.of(context).colorScheme.secondaryContainer,
          //   width: double.infinity,
          //   child: const Column(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Text(
          //         'Welcome to PRK EduTech AI',
          //         style: TextStyle(
          //           fontSize: 20,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       SizedBox(height: 8),
          //       Text(
          //         'Give Text / Image as input',
          //         style: TextStyle(fontSize: 16),
          //       ),
          //     ],
          //   ),
          // ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 80,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageService.translate('chat_welcome_message'),
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: message.role == 'Jeevaan AI'
                            ? Colors.blue[600]
                            : Colors.green[600],
                        child: Icon(
                          message.role == 'Jeevaan AI' ? Icons.medical_services : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.role == 'Jeevaan AI'
                                    ? Colors.blue[100]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.role,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(message.text),
                                ],
                              ),
                            ),
                            if (message.image != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  message.image!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Selected image preview
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: languageService.translate('chat_hint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: 'pickImage',
                      onPressed: _pickImage,
                      tooltip: 'Pick Image',
                      child: const Icon(Icons.photo),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}