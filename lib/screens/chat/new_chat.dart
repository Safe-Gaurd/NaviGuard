// 1. First, let's create a chat message model
// chat_message_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatMessage {
//   final String messageId;
//   final String senderId;
//   final String senderName;
//   final String senderPhotoURL;
//   final String content;
//   final DateTime timestamp;
//   final bool isRead;

//   ChatMessage({
//     required this.messageId,
//     required this.senderId,
//     required this.senderName,
//     required this.senderPhotoURL,
//     required this.content,
//     required this.timestamp,
//     this.isRead = false,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'senderId': senderId,
//       'senderName': senderName,
//       'senderPhotoURL': senderPhotoURL,
//       'content': content,
//       'timestamp': timestamp,
//       'isRead': isRead,
//     };
//   }

//   static ChatMessage fromSnapshot(DocumentSnapshot snap) {
//     final data = snap.data() as Map<String, dynamic>;
//     return ChatMessage(
//       messageId: snap.id,
//       senderId: data['senderId'] ?? '',
//       senderName: data['senderName'] ?? '',
//       senderPhotoURL: data['senderPhotoURL'] ?? '',
//       content: data['content'] ?? '',
//       timestamp: (data['timestamp'] as Timestamp).toDate(),
//       isRead: data['isRead'] ?? false,
//     );
//   }
// }

// 2. Let's create a chat room model
// chat_room_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatRoom {
//   final String roomId;
//   final String roomName;
//   final String roomType; // 'community' or 'direct'
//   final String communityType; // 'police', 'hospital', 'bloodbank', or null for direct chats
//   final List<String> participants;
//   final DateTime createdAt;
//   final DateTime lastMessageTime;
//   final String lastMessageContent;
//   final String lastMessageSenderId;

//   ChatRoom({
//     required this.roomId,
//     required this.roomName,
//     required this.roomType,
//     this.communityType = '',
//     required this.participants,
//     required this.createdAt,
//     required this.lastMessageTime,
//     this.lastMessageContent = '',
//     this.lastMessageSenderId = '',
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'roomName': roomName,
//       'roomType': roomType,
//       'communityType': communityType,
//       'participants': participants,
//       'createdAt': createdAt,
//       'lastMessageTime': lastMessageTime,
//       'lastMessageContent': lastMessageContent,
//       'lastMessageSenderId': lastMessageSenderId,
//     };
//   }

//   static ChatRoom fromSnapshot(DocumentSnapshot snap) {
//     final data = snap.data() as Map<String, dynamic>;
//     return ChatRoom(
//       roomId: snap.id,
//       roomName: data['roomName'] ?? '',
//       roomType: data['roomType'] ?? 'direct',
//       communityType: data['communityType'] ?? '',
//       participants: List<String>.from(data['participants'] ?? []),
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//       lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
//       lastMessageContent: data['lastMessageContent'] ?? '',
//       lastMessageSenderId: data['lastMessageSenderId'] ?? '',
//     );
//   }
// }

// 3. Now, let's create a chat provider to manage all chat functionality
// chat_provider.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:navigaurd/backend/models/chat_message_model.dart';
// import 'package:navigaurd/backend/models/chat_room_model.dart';
// import 'package:navigaurd/backend/models/user_model.dart';

// class ChatProvider extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
//   // Store current user data
//   UserModel? _currentUser;
//   UserModel get currentUser => _currentUser!;
  
//   // Store available community rooms
//   List<ChatRoom> _communityRooms = [];
//   List<ChatRoom> get communityRooms => _communityRooms;
  
//   // Store direct chat rooms for current user
//   List<ChatRoom> _directChatRooms = [];
//   List<ChatRoom> get directChatRooms => _directChatRooms;
  
//   // Store messages for the currently selected room
//   List<ChatMessage> _messages = [];
//   List<ChatMessage> get messages => _messages;
  
//   // Currently selected room
//   ChatRoom? _selectedRoom;
//   ChatRoom? get selectedRoom => _selectedRoom;
  
//   // Loading states
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
  
//   // Initialize community chat rooms based on officer titles
//   Future<void> initCommunityRooms() async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       // Fetch current user data
//       final userDoc = await _firestore.collection('users').doc(_currentUserId).get();
//       _currentUser = UserModel.fromSnapshot(userDoc);
      
//       // Check if community rooms exist, if not create them
//       final communityTypes = ['police', 'hospital', 'bloodbank'];
      
//       for (final type in communityTypes) {
//         final communityRoomQuery = await _firestore
//             .collection('chatRooms')
//             .where('roomType', isEqualTo: 'community')
//             .where('communityType', isEqualTo: type)
//             .limit(1)
//             .get();
            
//         if (communityRoomQuery.docs.isEmpty) {
//           // Create community room if it doesn't exist
//           final room = ChatRoom(
//             roomId: '', // Will be set by Firestore
//             roomName: '${type.substring(0, 1).toUpperCase()}${type.substring(1)} Community',
//             roomType: 'community',
//             communityType: type,
//             participants: [], // Will be populated as users join
//             createdAt: DateTime.now(),
//             lastMessageTime: DateTime.now(),
//           );
          
//           await _firestore.collection('chatRooms').add(room.toMap());
//         }
//       }
      
//       // Fetch and listen to community rooms
//       listenToCommunityRooms();
      
//       // Fetch and listen to direct chat rooms
//       listenToDirectChatRooms();
      
//     } catch (e) {
//       print("❌ Error initializing community rooms: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // Listen to community rooms
//   void listenToCommunityRooms() {
//     try {
//       // Get all community rooms
//       _firestore
//           .collection('chatRooms')
//           .where('roomType', isEqualTo: 'community')
//           .orderBy('lastMessageTime', descending: true)
//           .snapshots()
//           .listen((snapshot) {
//             _communityRooms = snapshot.docs
//                 .map((doc) => ChatRoom.fromSnapshot(doc))
//                 .toList();
                
//             // Filter rooms based on user's officer title if needed
//             if (_currentUser != null && _currentUser!.officerTitle.isNotEmpty) {
//               // If the user is part of an organization, always show their community
//               _communityRooms = _communityRooms.where((room) => 
//                 room.communityType == _currentUser!.officerTitle.toLowerCase() || 
//                 room.participants.contains(_currentUserId)).toList();
//             }
            
//             notifyListeners();
//           });
//     } catch (e) {
//       print("❌ Error listening to community rooms: $e");
//     }
//   }
  
//   // Listen to direct chat rooms
//   void listenToDirectChatRooms() {
//     try {
//       // Get direct chat rooms where the current user is a participant
//       _firestore
//           .collection('chatRooms')
//           .where('roomType', isEqualTo: 'direct')
//           .where('participants', arrayContains: _currentUserId)
//           .orderBy('lastMessageTime', descending: true)
//           .snapshots()
//           .listen((snapshot) {
//             _directChatRooms = snapshot.docs
//                 .map((doc) => ChatRoom.fromSnapshot(doc))
//                 .toList();
//             notifyListeners();
//           });
//     } catch (e) {
//       print("❌ Error listening to direct chat rooms: $e");
//     }
//   }
  
//   // Select a chat room and fetch messages
//   Future<void> selectChatRoom(ChatRoom room) async {
//     _isLoading = true;
//     _selectedRoom = room;
//     notifyListeners();
    
//     try {
//       // If this is a community room, add user to participants if not already there
//       if (room.roomType == 'community' && !room.participants.contains(_currentUserId)) {
//         await _firestore.collection('chatRooms').doc(room.roomId).update({
//           'participants': FieldValue.arrayUnion([_currentUserId])
//         });
//       }
      
//       // Listen to messages for the selected room
//       listenToMessages(room.roomId);
//     } catch (e) {
//       print("❌ Error selecting chat room: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // Listen to messages for a specific room
//   void listenToMessages(String roomId) {
//     try {
//       _firestore
//           .collection('chatRooms')
//           .doc(roomId)
//           .collection('messages')
//           .orderBy('timestamp', descending: true)
//           .snapshots()
//           .listen((snapshot) {
//             _messages = snapshot.docs
//                 .map((doc) => ChatMessage.fromSnapshot(doc))
//                 .toList();
//             notifyListeners();
            
//             // Mark messages as read
//             _markMessagesAsRead(roomId);
//           });
//     } catch (e) {
//       print("❌ Error listening to messages: $e");
//     }
//   }
  
//   // Mark messages as read
//   Future<void> _markMessagesAsRead(String roomId) async {
//     try {
//       final batch = _firestore.batch();
//       final unreadMessages = await _firestore
//           .collection('chatRooms')
//           .doc(roomId)
//           .collection('messages')
//           .where('isRead', isEqualTo: false)
//           .where('senderId', isNotEqualTo: _currentUserId)
//           .get();
          
//       for (final doc in unreadMessages.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }
      
//       await batch.commit();
//     } catch (e) {
//       print("❌ Error marking messages as read: $e");
//     }
//   }
  
//   // Send a message
//   Future<void> sendMessage(String content) async {
//     if (_selectedRoom == null || content.trim().isEmpty) return;
    
//     try {
//       final message = ChatMessage(
//         messageId: '',
//         senderId: _currentUserId,
//         senderName: _currentUser!.name,
//         senderPhotoURL: _currentUser!.photoURL,
//         content: content.trim(),
//         timestamp: DateTime.now(),
//       );
      
//       // Add message to the room's messages collection
//       await _firestore
//           .collection('chatRooms')
//           .doc(_selectedRoom!.roomId)
//           .collection('messages')
//           .add(message.toMap());
          
//       // Update room's last message info
//       await _firestore
//           .collection('chatRooms')
//           .doc(_selectedRoom!.roomId)
//           .update({
//             'lastMessageTime': DateTime.now(),
//             'lastMessageContent': content.trim(),
//             'lastMessageSenderId': _currentUserId,
//           });
//     } catch (e) {
//       print("❌ Error sending message: $e");
//     }
//   }
  
//   // Create a new direct chat with another user
//   Future<void> createDirectChat(UserModel otherUser) async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       // Check if a direct chat already exists with this user
//       final existingChatQuery = await _firestore
//           .collection('chatRooms')
//           .where('roomType', isEqualTo: 'direct')
//           .where('participants', arrayContains: _currentUserId)
//           .get();
          
//       final existingChat = existingChatQuery.docs.firstWhere(
//         (doc) {
//           final room = ChatRoom.fromSnapshot(doc);
//           return room.participants.contains(otherUser.uid);
//         },
//         orElse: () => null as DocumentSnapshot,
//       );
      
//       if (existingChat != null) {
//         // Chat already exists, select it
//         selectChatRoom(ChatRoom.fromSnapshot(existingChat));
//         return;
//       }
      
//       // Create a new direct chat room
//       final room = ChatRoom(
//         roomId: '',
//         roomName: otherUser.name, // For the current user, show the other user's name
//         roomType: 'direct',
//         participants: [_currentUserId, otherUser.uid],
//         createdAt: DateTime.now(),
//         lastMessageTime: DateTime.now(),
//       );
      
//       final roomRef = await _firestore.collection('chatRooms').add(room.toMap());
      
//       // Select the newly created room
//       final newRoom = ChatRoom(
//         roomId: roomRef.id,
//         roomName: room.roomName,
//         roomType: room.roomType,
//         participants: room.participants,
//         createdAt: room.createdAt,
//         lastMessageTime: room.lastMessageTime,
//       );
      
//       selectChatRoom(newRoom);
//     } catch (e) {
//       print("❌ Error creating direct chat: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // Fetch all users for direct messaging
//   Future<List<UserModel>> fetchUsers({String? filterByOfficerTitle}) async {
//     try {
//       QuerySnapshot querySnapshot;
      
//       if (filterByOfficerTitle != null && filterByOfficerTitle.isNotEmpty) {
//         // Filter users by officer title
//         querySnapshot = await _firestore
//             .collection('users')
//             .where('officerTitle', isEqualTo: filterByOfficerTitle)
//             .get();
//       } else {
//         // Get all users
//         querySnapshot = await _firestore.collection('users').get();
//       }
      
//       // Convert to user models and exclude the current user
//       return querySnapshot.docs
//           .map((doc) => UserModel.fromSnapshot(doc))
//           .where((user) => user.uid != _currentUserId)
//           .toList();
//     } catch (e) {
//       print("❌ Error fetching users: $e");
//       return [];
//     }
//   }
// }

// 4. Now create UI screens for chat functionality
// chat_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:navigaurd/backend/providers/chat_provider.dart';
// import 'package:navigaurd/screens/chat/chat_detail_screen.dart';
// import 'package:navigaurd/screens/chat/new_chat_screen.dart';

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
  
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
    
//     // Initialize chat rooms
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ChatProvider>(context, listen: false).initCommunityRooms();
//     });
//   }
  
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Direct'),
//             Tab(text: 'Communities'),
//           ],
//         ),
//       ),
//       body: Consumer<ChatProvider>(
//         builder: (context, chatProvider, child) {
//           if (chatProvider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
          
//           return TabBarView(
//             controller: _tabController,
//             children: [
//               // Direct Chats Tab
//               _buildDirectChatsTab(chatProvider),
              
//               // Community Chats Tab
//               _buildCommunityChatsTab(chatProvider),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.message),
//         onPressed: () {
//           Navigator.push(
//             context, 
//             MaterialPageRoute(builder: (context) => const NewChatScreen())
//           );
//         },
//       ),
//     );
//   }
  
//   Widget _buildDirectChatsTab(ChatProvider chatProvider) {
//     if (chatProvider.directChatRooms.isEmpty) {
//       return const Center(
//         child: Text('No direct chats yet. Start a conversation!'),
//       );
//     }
    
//     return ListView.builder(
//       itemCount: chatProvider.directChatRooms.length,
//       itemBuilder: (context, index) {
//         final room = chatProvider.directChatRooms[index];
//         return _buildChatRoomTile(room, chatProvider);
//       },
//     );
//   }
  
//   Widget _buildCommunityChatsTab(ChatProvider chatProvider) {
//     if (chatProvider.communityRooms.isEmpty) {
//       return const Center(
//         child: Text('No community chats available'),
//       );
//     }
    
//     return ListView.builder(
//       itemCount: chatProvider.communityRooms.length,
//       itemBuilder: (context, index) {
//         final room = chatProvider.communityRooms[index];
//         return _buildChatRoomTile(room, chatProvider);
//       },
//     );
//   }
  
//   Widget _buildChatRoomTile(ChatRoom room, ChatProvider chatProvider) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: room.roomType == 'community' 
//             ? _getCommunityColor(room.communityType)
//             : Colors.blue,
//         child: room.roomType == 'community'
//             ? _getCommunityIcon(room.communityType)
//             : const Icon(Icons.person),
//       ),
//       title: Text(room.roomName),
//       subtitle: room.lastMessageContent.isNotEmpty
//           ? Text(
//               room.lastMessageSenderId == chatProvider.currentUser.uid
//                   ? 'You: ${room.lastMessageContent}'
//                   : room.lastMessageContent,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             )
//           : const Text('No messages yet'),
//       trailing: Text(
//         _formatDateTime(room.lastMessageTime),
//         style: TextStyle(
//           fontSize: 12,
//           color: Colors.grey,
//         ),
//       ),
//       onTap: () {
//         chatProvider.selectChatRoom(room);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const ChatDetailScreen(),
//           ),
//         );
//       },
//     );
//   }
  
//   Color _getCommunityColor(String communityType) {
//     switch (communityType.toLowerCase()) {
//       case 'police':
//         return Colors.blue;
//       case 'hospital':
//         return Colors.red;
//       case 'bloodbank':
//         return Colors.red.shade900;
//       default:
//         return Colors.grey;
//     }
//   }
  
//   Icon _getCommunityIcon(String communityType) {
//     switch (communityType.toLowerCase()) {
//       case 'police':
//         return const Icon(Icons.local_police);
//       case 'hospital':
//         return const Icon(Icons.local_hospital);
//       case 'bloodbank':
//         return const Icon(Icons.bloodtype);
//       default:
//         return const Icon(Icons.group);
//     }
//   }
  
//   String _formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
    
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }

// 5. Chat detail screen
// chat_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:navigaurd/backend/providers/chat_provider.dart';
// import 'package:navigaurd/backend/models/chat_message_model.dart';

// class ChatDetailScreen extends StatefulWidget {
//   const ChatDetailScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatDetailScreen> createState() => _ChatDetailScreenState();
// }

// class _ChatDetailScreenState extends State<ChatDetailScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ChatProvider>(
//       builder: (context, chatProvider, child) {
//         final selectedRoom = chatProvider.selectedRoom;
        
//         if (selectedRoom == null) {
//           return const Scaffold(
//             body: Center(child: Text('No chat selected')),
//           );
//         }
        
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(selectedRoom.roomName),
//             actions: [
//               if (selectedRoom.roomType == 'community')
//                 IconButton(
//                   icon: Icon(Icons.info_outline),
//                   onPressed: () {
//                     // Show community info dialog with member count
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text('${selectedRoom.roomName} Info'),
//                         content: Text('${selectedRoom.participants.length} members'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text('Close'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//             ],
//           ),
//           body: Column(
//             children: [
//               // Messages list
//               Expanded(
//                 child: chatProvider.messages.isEmpty
//                     ? Center(
//                         child: Text(
//                           'No messages yet. Start a conversation!',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       )
//                     : ListView.builder(
//                         controller: _scrollController,
//                         reverse: true,
//                         itemCount: chatProvider.messages.length,
//                         itemBuilder: (context, index) {
//                           return _buildMessageItem(
//                             chatProvider.messages[index],
//                             chatProvider.currentUser.uid,
//                           );
//                         },
//                       ),
//               ),
              
//               // Message input
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     // Text input
//                     Expanded(
//                       child: TextField(
//                         controller: _messageController,
//                         decoration: const InputDecoration(
//                           hintText: 'Type a message',
//                           border: InputBorder.none,
//                         ),
//                         minLines: 1,
//                         maxLines: 5,
//                       ),
//                     ),
                    
//                     // Send button
//                     IconButton(
//                       icon: const Icon(Icons.send),
//                       color: Theme.of(context).primaryColor,
//                       onPressed: () {
//                         if (_messageController.text.trim().isNotEmpty) {
//                           chatProvider.sendMessage(_messageController.text);
//                           _messageController.clear();
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildMessageItem(ChatMessage message, String currentUserId) {
//     final isCurrentUser = message.senderId == currentUserId;
    
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: isCurrentUser
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (!isCurrentUser) ...[
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: message.senderPhotoURL.isNotEmpty
//                   ? NetworkImage(message.senderPhotoURL)
//                   : null,
//               child: message.senderPhotoURL.isEmpty
//                   ? Text(message.senderName[0].toUpperCase())
//                   : null,
//             ),
//             const SizedBox(width: 8),
//           ],
          
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isCurrentUser
//                     ? Theme.of(context).primaryColor
//                     : Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (!isCurrentUser)
//                     Text(
//                       message.senderName,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                         color: isCurrentUser ? Colors.white70 : Colors.black54,
//                       ),
//                     ),
//                   Text(
//                     message.content,
//                     style: TextStyle(
//                       color: isCurrentUser ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _formatMessageTime(message.timestamp),
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: isCurrentUser ? Colors.white70 : Colors.black54,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   String _formatMessageTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final messageDate = DateTime(
//       dateTime.year,
//       dateTime.month,
//       dateTime.day,
//     );
    
//     if (messageDate == today) {
//       return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//     } else if (messageDate == yesterday) {
//       return 'Yesterday ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//     } else {
//       return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//     }
//   }
// }

// 6. New chat screen
// new_chat_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:navigaurd/backend/providers/chat_provider.dart';
// import 'package:navigaurd/backend/models/user_model.dart';
// import 'package:navigaurd/screens/chat/chat_detail_screen.dart';

// class NewChatScreen extends StatefulWidget {
//   const NewChatScreen({Key? key}) : super(key: key);

//   @override
//   State<NewChatScreen> createState() => _NewChatScreenState();
// }

// class _NewChatScreenState extends State<NewChatScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<UserModel> _users = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
  
//   final List<String> _officerTitles = ['Police', 'Hospital', 'Bloodbank'];
  
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _officerTitles.length + 1, vsync: this);
//     _loadUsers();
//   }
  
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
  
//   Future<void> _loadUsers() async {
//     setState(() {
//       _isLoading = true;
//     });
    
//     try {
//       final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//       _users = await chatProvider.fetchUsers();
//     } catch (e) {
//       print("❌ Error loading users: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
  
//   List<UserModel> _getFilteredUsers(String? officerTitle) {
//     // First filter by search query
//     var filteredUsers = _users.where((user) => 
//       user.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
//     // Then filter by officer title if specified
//     if (officerTitle != null) {
//       filteredUsers = filteredUsers.where((user) => 
//         user.officerTitle.toLowerCase() == officerTitle.toLowerCase()).toList();
//     }
    
//     return filteredUsers;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('New Chat'),
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabs: [
//             const Tab(text: 'All'),
//             ..._officerTitles.map((title) => Tab(text: title)).toList(),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search users',
//                 prefixIcon: const Icon(Icons.search),
//                 // Continuing from new_chat_screen.dart
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   vertical: 8.0,
//                   horizontal: 16.0,
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//             ),
//           ),
          
//           // User list
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       // All users tab
//                       _buildUserList(null),
                      
//                       // Officer-specific tabs
//                       ..._officerTitles.map((title) => _buildUserList(title)).toList(),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildUserList(String? officerTitle) {
//     final filteredUsers = _getFilteredUsers(officerTitle);
    
//     if (filteredUsers.isEmpty) {
//       return Center(
//         child: Text(
//           _searchQuery.isEmpty
//               ? 'No ${officerTitle ?? ''} users found'
//               : 'No results for "$_searchQuery"',
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }
    
//     return ListView.builder(
//       itemCount: filteredUsers.length,
//       itemBuilder: (context, index) {
//         final user = filteredUsers[index];
//         return _buildUserTile(user);
//       },
//     );
//   }
  
//   Widget _buildUserTile(UserModel user) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundImage: user.photoURL.isNotEmpty
//             ? NetworkImage(user.photoURL)
//             : null,
//         child: user.photoURL.isEmpty
//             ? Text(user.name[0].toUpperCase())
//             : null,
//       ),
//       title: Text(user.name),
//       subtitle: Text(
//         user.officerTitle.isNotEmpty
//             ? user.officerTitle
//             : 'User',
//       ),
//       trailing: Icon(
//         _getOfficerIcon(user.officerTitle),
//         color: _getOfficerColor(user.officerTitle),
//       ),
//       onTap: () async {
//         final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//         await chatProvider.createDirectChat(user);
        
//         // Navigate to chat detail screen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const ChatDetailScreen(),
//           ),
//         );
//       },
//     );
//   }
  
//   IconData _getOfficerIcon(String officerTitle) {
//     switch (officerTitle.toLowerCase()) {
//       case 'police':
//         return Icons.local_police;
//       case 'hospital':
//         return Icons.local_hospital;
//       case 'bloodbank':
//         return Icons.bloodtype;
//       default:
//         return Icons.person;
//     }
//   }
  
//   Color _getOfficerColor(String officerTitle) {
//     switch (officerTitle.toLowerCase()) {
//       case 'police':
//         return Colors.blue;
//       case 'hospital':
//         return Colors.red;
//       case 'bloodbank':
//         return Colors.red.shade900;
//       default:
//         return Colors.grey;
//     }
//   }
// }

// 7. Let's update your main.dart to include the chat provider
// main.dart modifications (add the following to your provider setup)

// Add this import
// import 'package:navigaurd/backend/providers/chat_provider.dart';

// // In your MultiProvider setup, add the ChatProvider
// MultiProvider(
//   providers: [
//     ChangeNotifierProvider(create: (context) => UserProvider()),
//     ChangeNotifierProvider(create: (context) => ChatProvider()),
//     // ... your other providers
//   ],
//   child: MaterialApp(
//     // ... your app configuration
//   ),
// )

// // 8. Modify your navigation to include chat screens
// // Here's an example of how to include a chat icon in your bottom navigation
// BottomNavigationBar(
//   items: const [
//     BottomNavigationBarItem(
//       icon: Icon(Icons.home),
//       label: 'Home',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.message),
//       label: 'Chats',
//     ),
//     // ... your other navigation items
//   ],
//   currentIndex: _selectedIndex,
//   onTap: (index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   },
// ),

// // Then in your body:
// IndexedStack(
//   index: _selectedIndex,
//   children: [
//     HomeScreen(),
//     ChatListScreen(),
//     // ... your other screens
//   ],
// )

// 9. Update the user model to include officer title field
// Make sure your UserModel class has the officerTitle field:

// // Inside user_model.dart, ensure you have:
// class UserModel {
//   final String uid;
//   final String name;
//   final String email;
//   final String phonenumber;
//   final String photoURL;
//   final String location;
//   final String officerTitle; // This is important for chat filtering

//   UserModel({
//     required this.uid,
//     required this.name,
//     required this.email,
//     required this.phonenumber,
//     required this.photoURL,
//     required this.location,
//     required this.officerTitle,
//   });

//   // ... rest of your UserModel implementation
// }