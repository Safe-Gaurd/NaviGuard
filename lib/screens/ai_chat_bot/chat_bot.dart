import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'widgets/typing_indicator.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

// Enhanced AiProvider with chat functionality
class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController scrollController = ScrollController();

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
      // Use the existing text_to_text endpoint
      final result = await _getTextResponse(text);

      // Add AI response
      _messages.add(ChatMessage(text: result, isUser: false));
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

  // Call the text_to_text API
  Future<String> _getTextResponse(String prompt) async {
    // Using your existing API client
    final response = await http.post(
      Uri.parse('http://10.0.43.124:5000/text_to_text'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['result'];
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
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

// Stateless Chat Screen
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const _ChatScreenContent(),
    );
  }
}

// Actual content of the chat screen
class _ChatScreenContent extends StatelessWidget {
  const _ChatScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final messageController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI Assistant'),
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
                  'Ask a question or just say hello',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "I'm here to help you!",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Feel free to ask about cows and their breeds.",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
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
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
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
                  hintText: 'Ask Your Questions Here',
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
                  ))),
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