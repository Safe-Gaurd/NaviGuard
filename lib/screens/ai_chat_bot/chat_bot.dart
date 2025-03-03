import 'dart:convert';
import 'package:formatted_text/formatted_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/ai_chat_bot/widgets/typing_indicator.dart';
import 'package:navigaurd/screens/maps/maps.dart';
import 'package:provider/provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isNavigation;
  final String? mapCommand;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isNavigation = false,
    this.mapCommand,
  }) : timestamp = timestamp ?? DateTime.now();
}

// Enhanced ChatProvider with navigation support
class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController scrollController = ScrollController();
  final String apiBaseUrl = 'https://ai-assisstance-chatbot.onrender.com/';

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  // Send message and get AI response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(text: text, isUser: true));
    _isTyping = true;
    notifyListeners();
    scrollToBottom();

    try {
      // Call the API endpoint
      final response = await http.post(
        Uri.parse('$apiBaseUrl/text_to_text_chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': text}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String aiMessage = responseData['result'];
        final bool isNavigation = responseData['is_navigation'] ?? false;

        // Check if there's a map command in the response
        String? mapCommand;
        if (aiMessage.contains("MAP_SCREEN:")) {
          final lines = aiMessage.split('\n');
          for (final line in lines) {
            if (line.trim().startsWith("MAP_SCREEN:")) {
              mapCommand = line.trim();
              break;
            }
          }
        }

        // Clean the message (remove map command if present)
        final cleanMessage = mapCommand != null
            ? aiMessage.replaceAll(mapCommand, '').trim()
            : aiMessage;

        // Add AI response
        _messages.add(ChatMessage(
          text: cleanMessage,
          isUser: false,
          isNavigation: isNavigation,
          mapCommand: mapCommand,
        ));

        // Handle navigation command if present
        if (mapCommand != null) {
          _handleMapCommand(mapCommand);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Add error message
      _messages.add(ChatMessage(
        text: 'Sorry, I encountered an error: $e',
        isUser: false,
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
      scrollToBottom();
    }
  }

  // Handle map commands by launching navigation
  void _handleMapCommand(String command) {
    // Example: MAP_SCREEN:destination=Hospital General;mode=driving
    try {
      final params = command.replaceFirst('MAP_SCREEN:', '').split(';');
      final Map<String, String> paramMap = {};

      for (final param in params) {
        final parts = param.split('=');
        if (parts.length == 2) {
          paramMap[parts[0]] = parts[1];
        }
      }

      final destination = paramMap['destination'];
      final mode = paramMap['mode'] ?? 'driving';

      if (destination != null) {
        // Here you would typically navigate to your map screen
        // For this example, we'll print what would happen
        print('Navigating to: $destination in mode: $mode');
      }
    } catch (e) {
      print('Error handling map command: $e');
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}

// Stateful Chat Screen
class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const _ChatScreenContent(),
    );
  }
}

// Content of the chat screen
class _ChatScreenContent extends StatelessWidget {
  const _ChatScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final messageController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NaviGuard Assistant'),
        backgroundColor: blueColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(context, provider),
          ),
          _buildMessageComposer(context, provider, messageController),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, ChatProvider provider) {
    return provider.messages.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome to NaviGuard Assistant',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "I'm here to help with navigation and safety!",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ask about nearby hospitals, reporting accidents, or directions.",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            controller: provider.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: provider.isTyping
                ? provider.messages.length + 1
                : provider.messages.length,
            itemBuilder: (context, index) {
              if (provider.isTyping && index == provider.messages.length) {
                return const GeminiStyleTypingIndicator();
              }

              final message = provider.messages[index];
              return _buildMessageBubble(context, message);
            },
          );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) _buildAvatar(isUser: false),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF4285F4)
                    : message.isNavigation
                        ? Color(
                            0xFFE3F2FD) // Light blue for navigation messages
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormattedText(
                    message.text
                        .replaceAll(
                            RegExp(
                                r'MAP_SCREEN:destination=.*?;mode=driving\.'),
                            '')
                        .trim(),
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  if (message.isNavigation && !message.isUser) ...[
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (message.mapCommand != null) {
                          // Extract destination from map command
                          final regex = RegExp(r'destination=(.*?)(;|$)');
                          final match = regex.firstMatch(message.mapCommand!);

                          if (match != null && match.groupCount >= 1) {
                            final destination = match.group(1);

                            // Navigate to MapScreen with the extracted parameters
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  destination: destination!,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Open Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        backgroundColor: isUser
            ? const Color(0xFF4285F4).withOpacity(0.8)
            : Colors.grey.shade200,
        radius: 16,
        child: Icon(
          isUser ? Icons.person : Icons.smart_toy_outlined,
          color: isUser ? Colors.white : const Color(0xFF4285F4),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildMessageComposer(
    BuildContext context,
    ChatProvider provider,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask about navigation, safety, or emergencies...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (text) {
                  provider.sendMessage(text);
                  controller.clear();
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF4285F4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                provider.sendMessage(controller.text);
                controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
