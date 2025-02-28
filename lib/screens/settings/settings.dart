import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(label: "Settings"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Settings Options
            _buildSettingsOption(
              icon: Icons.dark_mode,
              text: "Dark Mode",
              onTap: () {
                // TODO: Implement Dark Mode Toggle
              },
            ),
            _buildSettingsOption(
              icon: Icons.language,
              text: "Language",
              onTap: () {
                // TODO: Implement Language Selection
              },
            ),
            _buildSettingsOption(
              icon: Icons.lock,
              text: "Privacy & Security",
              onTap: () {
                // TODO: Navigate to Privacy Settings
              },
            ),
            _buildSettingsOption(
              icon: Icons.help_outline,
              text: "Help & Support",
              onTap: () {
                // TODO: Navigate to Help Page
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Widget to Build Settings Options
  Widget _buildSettingsOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(icon, color: isLogout ? Colors.red : blueColor),
        title: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}