import 'package:flutter/material.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(label: "Notification"),
      body: Center(
        child: Text("Notification"),
      ),
    );
  }


}