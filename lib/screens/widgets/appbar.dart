import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/notifications/notification.dart';
import 'package:navigaurd/screens/profile/user_profile.dart';
import 'package:navigaurd/screens/support&help/help.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final TextStyle? style;
  

  const CustomAppbar({
    super.key,
    required this.label,
    this.style,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        return AppBar(
          backgroundColor: blueColor,
          toolbarHeight: 70,
          // leading: Builder(
          //   builder: (context) => IconButton(
          //     icon: const Icon(Icons.menu),
          //     tooltip: 'Open Menu',
          //     onPressed: () {
          //       Scaffold.of(context).openDrawer();
          //     },
          //   ),
          // ),
          title: Text(
            label,
            style: style ??
                const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline_sharp),
              tooltip: 'Help',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SupportHelpScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: 'Notifications',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: provider.user.photoURL != ''
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(provider.user.photoURL!),
                    )
                  : CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Text(
                        provider.user.name[0].toUpperCase(),
                        style: const TextStyle(color: blueColor, fontWeight: FontWeight.bold),
                      ),
                    ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen()
                  ),
                );
              },
            ),
            const SizedBox(width: 15),
          ],
        );
      },
    );
  }
}
