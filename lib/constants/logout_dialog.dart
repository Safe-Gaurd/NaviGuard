import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class CustomDialog {
  const CustomDialog({Key? key});

  void showLogoutDialog({
    required BuildContext context,
    required String label,
    required String message,
    required String option1,
    void Function()? onPressed1,
    required String option2,
    void Function()? onPressed2,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/home/notification.jpg",
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                  //option1
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: CustomElevatedButton(
                      borderRadius: 15,
                      text: option1,
                      textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: backgroundColor),
                      onPressed: onPressed1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  //option2
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: CustomElevatedButton(
                      borderRadius: 15,
                      text: option2,
                      textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: backgroundColor),
                      onPressed: onPressed2,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
