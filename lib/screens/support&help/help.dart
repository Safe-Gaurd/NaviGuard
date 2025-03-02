import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/widgets/nav_bars/appbar.dart';

class SupportHelpScreen extends StatelessWidget {
  const SupportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(label: "Help & Support"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 100,
              color: blueColor,
            ),
            const SizedBox(height: 16),
            Text(
              "Need Help?",
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We're here to assist you! If you have any issues, please contact us.",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Implement your support contact logic
              },
              icon: const Icon(Icons.email_outlined, color: Colors.white),
              label: const Text("Contact Support"),
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: GoogleFonts.dmSans(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}