import 'package:flutter/material.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(label: "Change Password"),
      body: Center(
        child: Text("Change Password"),
      ),
    );
  }
}