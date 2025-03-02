import 'package:flutter/material.dart';
import 'package:navigaurd/backend/auth/auth_methods.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/logout_dialog.dart';
import 'package:navigaurd/screens/auth/selection.dart';
import 'package:navigaurd/screens/coins/coins.dart';
import 'package:navigaurd/screens/home/home.dart';
import 'package:navigaurd/screens/notifications/notification.dart';
import 'package:navigaurd/screens/profile/user_profile.dart';
import 'package:navigaurd/screens/settings/settings.dart';

class CustomSideBar extends StatelessWidget {
  final UserProvider provider;

  const CustomSideBar({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: blueColor),
              onDetailsPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const UserProfileScreen())),
              accountName: Text(
                provider.user.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                provider.user.email,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              currentAccountPicture: provider.user.photoURL != ''
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(provider.user.photoURL!),
                    )
                  : CircleAvatar(
                      child: Text(
                        provider.user.name[0],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
            const SizedBox(height: 10),

            NavbarItems(
              icon: Icons.home,
              label: "Home",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HomeScreen()));
              },
            ),
            NavbarItems(icon: Icons.person, label: "Profile", onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const UserProfileScreen()));
              },),
            NavbarItems(
              icon: Icons.notifications,
              label: "Notifications",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const NotificationScreen()));
              },
            ),
            NavbarItems(
              icon: Icons.settings,
              label: "Settings",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
              },
            ),
            NavbarItems(
              icon: Icons.currency_exchange_outlined,
              label: "NaviGuard Coins",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CoinsScreen()));
              },
            ),
            NavbarItems(
              icon: Icons.logout,
              label: "SignOut",
              onTap: () {
                const CustomDialog().showLogoutDialog(
                  context: context,
                  label: "LogOut",
                  message: "Are you sure you want to Log Out?",
                  option2: "Cancel",
                  onPressed2: () {
                    Navigator.of(context).pop();
                  },
                  option1: "Yes",
                  onPressed1: () {
                    AuthService().logout();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const UserTypeSelectionScreen()));
                  },
                );
              },
              labelColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

// Create a separate class for the NavbarItems
class NavbarItems extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;

  const NavbarItems({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: TextStyle(color: labelColor),
      ),
      onTap: onTap,
    );
  }
}