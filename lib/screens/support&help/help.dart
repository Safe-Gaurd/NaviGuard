import 'package:flutter/material.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';


class SupportHelpScreen extends StatelessWidget {
  const SupportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(label: "Help And Support"),
      body: Center(
        child: Text("Help & Support screen"),
      ),
    );
  }
}