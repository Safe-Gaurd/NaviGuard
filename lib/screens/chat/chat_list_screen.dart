import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/chat/chat_provider.dart';
import 'package:navigaurd/screens/chat/chat_room_model.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/screens/chat/chat_detail_screen.dart';
import 'package:navigaurd/screens/chat/new_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize chat rooms
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).initCommunityRooms();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColor,
        title: const Text('Chats'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Direct'),
            Tab(text: 'Communities'),
          ],
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Direct Chats Tab
              _buildDirectChatsTab(chatProvider),
              
              // Community Chats Tab
              _buildCommunityChatsTab(chatProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: blueColor,
        child: const Icon(Icons.message),
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const NewChatScreen())
          );
        },
      ),
    );
  }
  
  Widget _buildDirectChatsTab(ChatProvider chatProvider) {
    if (chatProvider.directChatRooms.isEmpty) {
      return const Center(
        child: Text('No direct chats yet. Start a conversation!'),
      );
    }
    
    return ListView.builder(
      itemCount: chatProvider.directChatRooms.length,
      itemBuilder: (context, index) {
        final room = chatProvider.directChatRooms[index];
        return _buildChatRoomTile(room, chatProvider);
      },
    );
  }
  
  Widget _buildCommunityChatsTab(ChatProvider chatProvider) {
    if (chatProvider.communityRooms.isEmpty) {
      return const Center(
        child: Text('No community chats available'),
      );
    }
    
    return ListView.builder(
      itemCount: chatProvider.communityRooms.length,
      itemBuilder: (context, index) {
        final room = chatProvider.communityRooms[index];
        return _buildChatRoomTile(room, chatProvider);
      },
    );
  }
  
  Widget _buildChatRoomTile(ChatRoom room, ChatProvider chatProvider) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: room.roomType == 'community' 
            ? _getCommunityColor(room.communityType)
            : Colors.blue,
        child: room.roomType == 'community'
            ? _getCommunityIcon(room.communityType)
            : const Icon(Icons.person),
      ),
      title: Text(room.roomName),
      subtitle: room.lastMessageContent.isNotEmpty
          ? Text(
              room.lastMessageSenderId == chatProvider.currentUser.uid
                  ? 'You: ${room.lastMessageContent}'
                  : room.lastMessageContent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : const Text('No messages yet'),
      trailing: Text(
        _formatDateTime(room.lastMessageTime),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      onTap: () {
        chatProvider.selectChatRoom(room);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatDetailScreen(),
          ),
        );
      },
    );
  }
  
  Color _getCommunityColor(String communityType) {
    switch (communityType.toLowerCase()) {
      case 'police':
        return Colors.blue;
      case 'hospital':
        return Colors.red;
      case 'bloodbank':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }
  
  Icon _getCommunityIcon(String communityType) {
    switch (communityType.toLowerCase()) {
      case 'police':
        return const Icon(Icons.local_police);
      case 'hospital':
        return const Icon(Icons.local_hospital);
      case 'bloodbank':
        return const Icon(Icons.bloodtype);
      default:
        return const Icon(Icons.group);
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}