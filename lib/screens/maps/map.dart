import 'package:flutter/material.dart';
import 'package:navigaurd/screens/maps/accident_report.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text("Map Screen"),
      ),
      floatingActionButton: CustomElevatedButton(
        text: "Report An Accident",
        onPressed: (){
          // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AccidentReportScreen()));
        },
        ),
    );
  }
}