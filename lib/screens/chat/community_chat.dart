import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';



class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Community> communities = [
    Community(
      name: 'Police Department',
      icon: Icons.local_police,
      messages: [
        ChatMessage(
          sender: 'Officer Ramesh',
          content: 'New traffic advisory for Bhimavaram area',
          time: '10:30 AM',
          isRead: true,
        ),
        ChatMessage(
          sender: 'Emergency Services',
          content: 'Safety tips for the upcoming storm',
          time: 'Yesterday',
          isRead: true,
        ),
      ],
    ),
    Community(
      name: 'BHimavaram Hospital',
      icon: Icons.local_hospital,
      messages: [
        ChatMessage(
          sender: 'Dr. Rama Devi',
          content: 'Free vaccination drive this weekend',
          time: '11:45 AM',
          isRead: false,
        ),
        ChatMessage(
          sender: 'Hospital Admin',
          content: 'New patient portal available now',
          time: '2 days ago',
          isRead: true,
        ),
      ],
    ),
    Community(
      name: 'Blood Bank',
      icon: Icons.bloodtype,
      messages: [
        ChatMessage(
          sender: 'Blood Bank Coordinator',
          content: 'Urgent: Need O- blood donors',
          time: '9:15 AM',
          isRead: false,
        ),
        ChatMessage(
          sender: 'Donation Center',
          content: 'Thank you to all who donated last week!',
          time: '5 days ago',
          isRead: true,
        ),
      ],
    ),
    Community(
      name: 'Fire Department',
      icon: Icons.fire_truck,
      messages: [
        ChatMessage(
          sender: 'Fire Chief',
          content: 'Fire safety month activities announced',
          time: '1:20 PM',
          isRead: true,
        ),
      ],
    ),
  ];

  final List<DirectChat> directChats = [
    DirectChat(
      name: 'Officer Ramesh',
      lastMessage: 'Thanks for reporting the incident',
      time: '4:45 PM',
      avatar: 'assets/avatar1.png',
      isOnline: true,
      unreadCount: 0,
    ),
    DirectChat(
      name: 'Dr. Rama Devi',
      lastMessage: 'Your appointment is confirmed for tomorrow',
      time: 'Yesterday',
      avatar: 'assets/avatar2.png',
      isOnline: false,
      unreadCount: 2,
    ),
    DirectChat(
      name: 'Nurse Keerthi',
      lastMessage: 'Please bring your insurance card',
      time: '2 days ago',
      avatar: 'assets/avatar3.png',
      isOnline: true,
      unreadCount: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Community Chat', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: backgroundColor,
                ),),
        backgroundColor: blueColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: backgroundColor,),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: backgroundColor,),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: backgroundColor,
          indicatorColor: backgroundColor,
          tabs: const [
            Tab(text: 'COMMUNITIES'),
            Tab(text: 'DIRECT CHATS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Communities Tab
          ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              return CommunityTile(
                community: communities[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityMessages(community: communities[index]),
                    ),
                  );
                },
              );
            },
          ),
          // Direct Chats Tab
          ListView.builder(
            itemCount: directChats.length,
            itemBuilder: (context, index) {
              return DirectChatTile(
                chat: directChats[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chat: directChats[index]),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: blueColor,
        child: const Icon(Icons.chat),
        onPressed: () {
          // Show dialog to start new chat
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Conversation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Join Community'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to community join screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('New Direct Message'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to contacts screen
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Community {
  final String name;
  final IconData icon;
  final List<ChatMessage> messages;

  Community({
    required this.name,
    required this.icon,
    required this.messages,
  });
}

class ChatMessage {
  final String sender;
  final String content;
  final String time;
  final bool isRead;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.time,
    required this.isRead,
  });
}

class DirectChat {
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;
  final bool isOnline;
  final int unreadCount;

  DirectChat({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    required this.isOnline,
    required this.unreadCount,
  });
}

class CommunityTile extends StatelessWidget {
  final Community community;
  final VoidCallback onTap;

  const CommunityTile({
    Key? key,
    required this.community,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int unreadCount = community.messages.where((msg) => !msg.isRead).length;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[700],
        child: Icon(
          community.icon,
          color: Colors.white,
        ),
      ),
      title: Text(
        community.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: community.messages.isNotEmpty
          ? Text(
              '${community.messages[0].sender}: ${community.messages[0].content}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : const Text('No messages yet'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            community.messages.isNotEmpty ? community.messages[0].time : '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class DirectChatTile extends StatelessWidget {
  final DirectChat chat;
  final VoidCallback onTap;

  const DirectChatTile({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(
              chat.name.substring(0, 1),
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (chat.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: blueColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class CommunityMessages extends StatelessWidget {
  final Community community;

  const CommunityMessages({Key? key, required this.community}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColor,
        title: Text(community.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: community.messages.length,
              itemBuilder: (context, index) {
                final message = community.messages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.blue[50],
                  child: InkWell(
                    onTap: () {
                      // Simulate opening a private chat with the sender
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chat: DirectChat(
                              name: message.sender,
                              lastMessage: message.content,
                              time: message.time,
                              avatar: 'assets/default.png',
                              isOnline: true,
                              unreadCount: 0,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                message.sender,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                message.time,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message.content,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: const Text('Direct Message'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue[700],
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        chat: DirectChat(
                                          name: message.sender,
                                          lastMessage: message.content,
                                          time: message.time,
                                          avatar: 'assets/default.png',
                                          isOnline: true,
                                          unreadCount: 0,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.blue[700],
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message to ${community.name}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue[700],
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final DirectChat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock messages for the chat
    final List<Map<String, dynamic>> messages = [
      {
        'isMe': false,
        'content': 'Hello there! How can I help you today?',
        'time': '10:01 AM',
      },
      {
        'isMe': true,
        'content': 'Hi! I had a question about the community event tomorrow.',
        'time': '10:02 AM',
      },
      {
        'isMe': false,
        'content': 'Of course, what would you like to know?',
        'time': '10:02 AM',
      },
      {
        'isMe': true,
        'content': 'What time does it start and do I need to bring anything?',
        'time': '10:03 AM',
      },
      {
        'isMe': false,
        'content': 'The event starts at 10 AM. Just bring yourself and maybe a water bottle if you want. Everything else will be provided!',
        'time': '10:05 AM',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColor,
        title: Row(
          children: [
            // CircleAvatar(
            //   backgroundColor: Colors.blue[100],
            //   radius: 16,
            //   child: Text(
            //     chat.name.substring(0, 1),
            //     style: TextStyle(
            //       color: Colors.blue[800],
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  chat.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: chat.isOnline ? blueColor : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['isMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: message['isMe'] ? Colors.blue[700] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['content'],
                          style: TextStyle(
                            color: message['isMe'] ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['time'],
                          style: TextStyle(
                            color: message['isMe']
                                ? Colors.blue[100]
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  color: Colors.grey[600],
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.grey[600],
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue[700],
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}