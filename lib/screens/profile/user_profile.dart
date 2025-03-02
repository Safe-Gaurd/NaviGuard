import 'package:flutter/material.dart';
import 'package:navigaurd/screens/auth/selection.dart';
import 'package:navigaurd/screens/coins/coins.dart';
import 'package:navigaurd/screens/widgets/nav_bars/appbar.dart';
import 'package:navigaurd/screens/widgets/nav_bars/side_navbar.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/auth/auth_methods.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/logout_dialog.dart';
import 'package:navigaurd/screens/notifications/notification.dart';
import 'package:navigaurd/screens/profile/change_password.dart';
import 'package:navigaurd/screens/profile/edit_profile.dart';
import 'package:navigaurd/screens/settings/settings.dart';
import 'package:navigaurd/screens/support&help/help.dart';

class UserProfileScreen extends StatelessWidget {
  final Function()? onTap;
  const UserProfileScreen({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, provider, _) {
      return Scaffold(
        appBar: CustomAppbar(
          label: "Profile",
        ),
        drawer: CustomSideBar(provider: provider),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white.withOpacity(0.6),
              child: Column(
                children: [
                  Stack(
                    children: [
                      provider.user.photoURL == ''
                          ? CircleAvatar(
                            radius: 60,
                            backgroundColor: blueColor,
                              child: Text(
                                provider.user.name[0],
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  NetworkImage(provider.user.photoURL!),
                              backgroundColor: Colors.blueAccent,
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(
                                          // userProvider: provider,
                                          ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                        provider.user.phonenumber,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  ProfileMenuItem(
                    icon: Icons.person,
                    text: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(
                              // userProvider: provider,
                              ),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.lock,
                    text: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.currency_exchange,
                    text: 'Naviguard Coins',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CoinsScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.settings,
                    text: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications,
                    text: 'Notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.help,
                    text: 'Help',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportHelpScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ProfileMenuItem(
                    icon: Icons.logout,
                    text: 'Logout',
                    onTap: (){
                      const CustomDialog().showLogoutDialog(
                        context: context, 
                        label: "LogOut", 
                        message: "Are you sure you want to  Log Out?", 
                        option2: "Cancel",
                        onPressed2: () {
                          Navigator.of(context).pop();
                        }, 
                        option1: "Yes",
                        onPressed1: () {
                            AuthService().logout();
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(builder: (context)=> const UserTypeSelectionScreen()));
                          },
                      );
                    },
                    textColor: Colors.red, 
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.blueAccent, size: 16),
          ],
        ),
      ),
    );
  }
}
