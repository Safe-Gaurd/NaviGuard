import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/home/home.dart';
import 'package:navigaurd/screens/support&help/help.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';

class ReportAnalysisScreen extends StatelessWidget {
  const ReportAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(label: "Report Analysis")
    );
  }
}