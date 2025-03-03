// import 'package:flutter/material.dart';
// import 'package:navigaurd/screens/chat/chat_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:navigaurd/screens/chat/chat_list_screen.dart';

// class ChatNotificationWidget extends StatelessWidget {
//   const ChatNotificationWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ChatProvider>(
//       builder: (context, chatProvider, child) {
//         // Initialize chat provider if needed
//         if (!chatProvider.isInitialized) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             chatProvider.initialize();
//           });
//           return const SizedBox.shrink();
//         }
        
//         // Listen for unread messages
//         return StreamBuilder<int>(
//           stream: chatProvider.unreadMessagesCount,
//           builder: (context, snapshot) {
//             final unreadCount = snapshot.data ?? 0;
            
//             if (unreadCount == 0) {
//               return const SizedBox.shrink();
//             }
            
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const ChatListScreen()),
//                 );
//               },
//               child: Container(
//                 margin: const EdgeInsets.all(8.0),
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.message, color: Colors.white, size: 16),
//                     const SizedBox(width: 4),
//                     Text(
//                       '$unreadCount new message${unreadCount > 1 ? 's' : ''}',
//                       style: const TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }