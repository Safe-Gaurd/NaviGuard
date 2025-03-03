import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/chat/chat_message_model.dart';
import 'package:navigaurd/screens/chat/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({Key? key}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final selectedRoom = chatProvider.selectedRoom;

        if (selectedRoom == null) {
          return const Scaffold(
            body: Center(child: Text('No chat selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(selectedRoom.roomName),
            backgroundColor: blueColor,
            actions: [
              if (selectedRoom.roomType == 'community')
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    // Show community info dialog with member count
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('${selectedRoom.roomName} Info'),
                        content:
                            Text('${selectedRoom.participants.length} members'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              // Messages list
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet. Start a conversation!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageItem(
                            chatProvider.messages[index],
                            chatProvider.currentUser.uid,
                          );
                        },
                      ),
              ),

              // Message input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),

                    // Send button
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: blueColor,
                      ),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          chatProvider.sendMessage(_messageController.text);
                          _messageController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message, String currentUserId) {
    final isCurrentUser = message.senderId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.senderPhotoURL.isNotEmpty
                  ? NetworkImage(message.senderPhotoURL)
                  : null,
              child: message.senderPhotoURL.isEmpty
                  ? Text(message.senderName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? blueColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isCurrentUser ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (messageDate == today) {
      return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
