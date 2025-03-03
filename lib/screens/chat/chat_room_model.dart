import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String roomId;
  final String roomName;
  final String roomType; // 'direct' or 'community'
  final String communityType; // 'police', 'hospital', 'bloodbank', 'users'
  final List<String> participants;
  final List<String> members;
  final String lastMessageContent;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final DateTime createdAt;

  ChatRoom({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    this.communityType = '',
    this.participants = const [],
    this.members = const [],
    this.lastMessageContent = '',
    this.lastMessageSenderId = '',
    required this.lastMessageTime,
    required this.createdAt,
  });

  factory ChatRoom.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    
    return ChatRoom(
      roomId: snapshot.id,
      roomName: data['roomName'] ?? '',
      roomType: data['roomType'] ?? '',
      communityType: data['communityType'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      members: List<String>.from(data['members'] ?? []),
      lastMessageContent: data['lastMessageContent'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomName': roomName,
      'roomType': roomType,
      'communityType': communityType,
      'participants': participants,
      'members': members,
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime,
      'createdAt': createdAt,
    };
  }
}