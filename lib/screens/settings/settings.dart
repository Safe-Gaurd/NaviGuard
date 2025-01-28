import 'package:flutter/material.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(label: "Settings"),
      body: Center(
        child: Text("Settings"),
      ),
    );
  }

}