import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/dash_cam/recorded.dart';
import 'package:navigaurd/screens/dash_cam/recording.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';

class DashcamScreen extends StatefulWidget {
  const DashcamScreen({super.key});

  @override
  _DashcamScreenState createState() => _DashcamScreenState();
}

class _DashcamScreenState extends State<DashcamScreen> {
  int selectedScreen = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(label: "DashCam"),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedScreen == 0 ? Colors.white : blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 2,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedScreen = 0;
                      });
                    },
                    child: Text(
                      'Recording',
                      style: TextStyle(
                        color: selectedScreen == 0 ? blueColor : backgroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedScreen == 1 ? Colors.white : blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 2,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedScreen = 1;
                      });
                    },
                    child: Text(
                      'Recorded',
                      style: TextStyle(
                        color: selectedScreen == 1 ? blueColor : backgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: selectedScreen == 0
                ?RecordingScreen()
                : RecordedScreen(),
          ),
        ],
      ),
    );
  }
}
