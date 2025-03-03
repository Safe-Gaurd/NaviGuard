import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navigaurd/backend/models/user_model.dart';
import 'package:navigaurd/screens/chat/chat_message_model.dart';
import 'package:navigaurd/screens/chat/chat_room_model.dart';


class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
  // Store current user data
  UserModel? _currentUser;
  UserModel get currentUser => _currentUser!;
  
  // Store available community rooms
  List<ChatRoom> _communityRooms = [];
  List<ChatRoom> get communityRooms => _communityRooms;
  
  // Store direct chat rooms for current user
  List<ChatRoom> _directChatRooms = [];
  List<ChatRoom> get directChatRooms => _directChatRooms;
  
  // Store messages for the currently selected room
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  
  // Currently selected room
  ChatRoom? _selectedRoom;
  ChatRoom? get selectedRoom => _selectedRoom;
  
  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Initialize community chat rooms based on officer titles
  Future<void> initCommunityRooms() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Fetch current user data
      final userDoc = await _firestore.collection('users').doc(_currentUserId).get();
      _currentUser = UserModel.fromSnapshot(userDoc);
      
      // Check if community rooms exist, if not create them
      final communityTypes = ['police', 'hospital', 'bloodbank', 'users'];
      
      for (final type in communityTypes) {
        final communityRoomQuery = await _firestore
            .collection('chatRooms')
            .where('roomType', isEqualTo: 'community')
            .where('communityType', isEqualTo: type)
            .limit(1)
            .get();
            
        if (communityRoomQuery.docs.isEmpty) {
          // Create community room if it doesn't exist
          final room = ChatRoom(
            roomId: '', // Will be set by Firestore
            roomName: '${type.substring(0, 1).toUpperCase()}${type.substring(1)} Community',
            roomType: 'community',
            communityType: type,
            participants: [], // Will be populated as users join
            createdAt: DateTime.now(),
            lastMessageTime: DateTime.now(),
          );
          
          await _firestore.collection('chatRooms').add(room.toMap());
        }
      }
      
      // Fetch and listen to community rooms
      listenToCommunityRooms();
      
      // Fetch and listen to direct chat rooms
      listenToDirectChatRooms();
      
    } catch (e) {
      print("❌ Error initializing community rooms: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Listen to community rooms
  void listenToCommunityRooms() {
    try {
      // Get all community rooms
      _firestore
          .collection('chatRooms')
          .where('roomType', isEqualTo: 'community')
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .listen((snapshot) {
            _communityRooms = snapshot.docs
                .map((doc) => ChatRoom.fromSnapshot(doc))
                .toList();
                
            // Filter rooms based on user's officer title if needed
            if (_currentUser != null && _currentUser!.officerTitle.isNotEmpty) {
              // If the user is part of an organization, always show their community
              _communityRooms = _communityRooms.where((room) => 
                room.communityType == _currentUser!.officerTitle.toLowerCase() || 
                room.participants.contains(_currentUserId)).toList();
            }
            
            notifyListeners();
          });
    } catch (e) {
      print("❌ Error listening to community rooms: $e");
    }
  }
  
  // Listen to direct chat rooms
  void listenToDirectChatRooms() {
    try {
      // Get direct chat rooms where the current user is a participant
      _firestore
          .collection('chatRooms')
          .where('roomType', isEqualTo: 'direct')
          .where('participants', arrayContains: _currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .listen((snapshot) {
            _directChatRooms = snapshot.docs
                .map((doc) => ChatRoom.fromSnapshot(doc))
                .toList();
            notifyListeners();
          });
    } catch (e) {
      print("❌ Error listening to direct chat rooms: $e");
    }
  }
  
  // Select a chat room and fetch messages
  Future<void> selectChatRoom(ChatRoom room) async {
    _isLoading = true;
    _selectedRoom = room;
    notifyListeners();
    
    try {
      // If this is a community room, add user to participants if not already there
      if (room.roomType == 'community' && !room.participants.contains(_currentUserId)) {
        await _firestore.collection('chatRooms').doc(room.roomId).update({
          'participants': FieldValue.arrayUnion([_currentUserId])
        });
      }
      
      // Listen to messages for the selected room
      listenToMessages(room.roomId);
    } catch (e) {
      print("❌ Error selecting chat room: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Listen to messages for a specific room
  void listenToMessages(String roomId) {
    try {
      _firestore
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
            _messages = snapshot.docs
                .map((doc) => ChatMessage.fromSnapshot(doc))
                .toList();
            notifyListeners();
            
            // Mark messages as read
            _markMessagesAsRead(roomId);
          });
    } catch (e) {
      print("❌ Error listening to messages: $e");
    }
  }
  
  // Mark messages as read
  Future<void> _markMessagesAsRead(String roomId) async {
    try {
      final batch = _firestore.batch();
      final unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: _currentUserId)
          .get();
          
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      print("❌ Error marking messages as read: $e");
    }
  }
  
  // Send a message
  Future<void> sendMessage(String content) async {
    if (_selectedRoom == null || content.trim().isEmpty) return;
    
    try {
      final message = ChatMessage(
        messageId: '',
        senderId: _currentUserId,
        senderName: _currentUser!.name,
        senderPhotoURL: _currentUser!.photoURL ?? "",
        content: content.trim(),
        timestamp: DateTime.now(),
      );
      
      // Add message to the room's messages collection
      await _firestore
          .collection('chatRooms')
          .doc(_selectedRoom!.roomId)
          .collection('messages')
          .add(message.toMap());
          
      // Update room's last message info
      await _firestore
          .collection('chatRooms')
          .doc(_selectedRoom!.roomId)
          .update({
            'lastMessageTime': DateTime.now(),
            'lastMessageContent': content.trim(),
            'lastMessageSenderId': _currentUserId,
          });
    } catch (e) {
      print("❌ Error sending message: $e");
    }
  }
  
  // Create a new direct chat with another user
  Future<bool> createDirectChat(UserModel otherUser) async {
  try {
    // Get the current user
    final currentUser = _currentUser;
    
    // Safety check
    if (currentUser == null || currentUser.uid.isEmpty) {
      print("❌ Current user is null or has no UID");
      return false;
    }
    
    // Create a unique room ID using both user IDs, sorted alphabetically
    // This ensures the same room is used if these users chat again
    final List<String> userIds = [currentUser.uid, otherUser.uid];
    userIds.sort(); // Sort alphabetically
    final roomId = "direct_${userIds[0]}_${userIds[1]}";
    
    // Check if chat already exists
    bool chatExists = false;
    for (final room in directChatRooms) {
      if (room.roomId == roomId) {
        chatExists = true;
        selectChatRoom(room); // Select the existing room
        break;
      }
    }
    
    if (!chatExists) {
      // Create a new chat room
      final newRoom = ChatRoom(
        roomId: roomId,
        roomName: otherUser.name,
        roomType: 'direct',
        members: [currentUser.uid, otherUser.uid],
        lastMessageContent: '',
        lastMessageSenderId: '',
        lastMessageTime: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore.collection('chatRooms').doc(roomId).set({
        'roomId': newRoom.roomId,
        'roomName': newRoom.roomName,
        'roomType': newRoom.roomType,
        'members': newRoom.members,
        'lastMessageContent': newRoom.lastMessageContent,
        'lastMessageSenderId': newRoom.lastMessageSenderId,
        'lastMessageTime': newRoom.lastMessageTime,
        'createdAt': newRoom.createdAt,
        'memberDetails': {
          currentUser.uid: {
            'name': currentUser.name,
            'photoURL': currentUser.photoURL,
          },
          otherUser.uid: {
            'name': otherUser.name,
            'photoURL': otherUser.photoURL,
          }
        }
      });
      
      // Add to local list and select it
      directChatRooms.add(newRoom);
      selectChatRoom(newRoom);
      notifyListeners();
    }
    
    return true;
  } catch (e) {
    print("❌ Error creating direct chat: $e");
    return false;
  }
}
  
  // Fetch all users for direct messaging
  Future<List<UserModel>> fetchUsers({String? filterByOfficerTitle}) async {
    try {
      QuerySnapshot querySnapshot;
      
      if (filterByOfficerTitle != null && filterByOfficerTitle.isNotEmpty) {
        // Filter users by officer title
        querySnapshot = await _firestore
            .collection('users')
            .where('officerTitle', isEqualTo: filterByOfficerTitle)
            .get();
      } else {
        // Get all users
        querySnapshot = await _firestore.collection('users').get();
      }
      
      // Convert to user models and exclude the current user
      return querySnapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .where((user) => user.uid != _currentUserId)
          .toList();
    } catch (e) {
      print("❌ Error fetching users: $e");
      return [];
    }
  }
}
