import 'package:flutter/material.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/chat/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/models/user_model.dart';
import 'package:navigaurd/screens/chat/chat_detail_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  final List<String> _officerTitles = ['Police', 'Hospital', 'Bloodbank'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _officerTitles.length + 1, vsync: this);
    _loadUsers();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _users = await chatProvider.fetchUsers();
      
      // Debug: Print users to verify they're loading correctly
      print("📝 Loaded ${_users.length} users");
      for (var user in _users) {
        print("User: ${user.name}, ID: ${user.uid}, Officer: ${user.officerTitle}");
      }
    } catch (e) {
      print("❌ Error loading users: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<UserModel> _getFilteredUsers(String? officerTitle) {
    // First filter by search query
    var filteredUsers = _users.where((user) => 
      user.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    // Then filter by officer title if specified
    if (officerTitle != null) {
      filteredUsers = filteredUsers.where((user) => 
        user.officerTitle.toLowerCase() == officerTitle.toLowerCase()).toList();
    }
    
    return filteredUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColor,
        title: const Text('New Chat'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'All'),
            ..._officerTitles.map((title) => Tab(text: title)).toList(),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // All users tab
                      _buildUserList(null),
                      
                      // Officer-specific tabs
                      ..._officerTitles.map((title) => _buildUserList(title)).toList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserList(String? officerTitle) {
    final filteredUsers = _getFilteredUsers(officerTitle);
    
    if (filteredUsers.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No ${officerTitle ?? ''} users found'
              : 'No results for "$_searchQuery"',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserTile(user);
      },
    );
  }
  
  Widget _buildUserTile(UserModel user) {
    // Get the current user for comparison
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    
    // Skip creating chat with yourself
    if (user.uid == currentUser.uid) {
      return const SizedBox.shrink(); // Don't show current user in the list
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
            ? NetworkImage(user.photoURL!)
            : null,
        child: user.photoURL == null || user.photoURL!.isEmpty
            ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(user.name),
      subtitle: Text(
        user.officerTitle.isNotEmpty
            ? user.officerTitle
            : 'User',
      ),
      trailing: Icon(
        _getOfficerIcon(user.officerTitle),
        color: _getOfficerColor(user.officerTitle),
      ),
      onTap: () async {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
          
          final chatProvider = Provider.of<ChatProvider>(context, listen: false);
          final success = await chatProvider.createDirectChat(user);
          
          // Close loading dialog
          Navigator.pop(context);
          
          if (success) {
            // Navigate to chat detail screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatDetailScreen(),
              ),
            );
          } else {
            // Show error if chat creation failed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create chat. Please try again.')),
            );
          }
        } catch (e) {
          // Close loading dialog if still showing
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          
          print("❌ Error creating chat: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      },
    );
  }
  
  IconData _getOfficerIcon(String officerTitle) {
    switch (officerTitle.toLowerCase()) {
      case 'police':
        return Icons.local_police;
      case 'hospital':
        return Icons.local_hospital;
      case 'bloodbank':
        return Icons.bloodtype;
      default:
        return Icons.person;
    }
  }
  
  Color _getOfficerColor(String officerTitle) {
    switch (officerTitle.toLowerCase()) {
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
}