import 'package:direct_caller_sim_choice/direct_caller_sim_choice.dart';
import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/screens/auth/widgets/customtextformfield.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class FavPersonCallScreen extends StatefulWidget {
  const FavPersonCallScreen({super.key});

  @override
  State<FavPersonCallScreen> createState() => FavPersonCallScreenState();
}

class FavPersonCallScreenState extends State<FavPersonCallScreen> {
  final TextEditingController phoneController = TextEditingController();

  Future<void> _makeCall() async {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isNotEmpty) {
      bool? result = DirectCaller().makePhoneCall('+91$phoneNumber');
      if (result != true) {
        toastMessage(
            context: context,
            message: "Failed to make the call. Please try again.",
            leadingIcon: const Icon(Icons.message),
          toastColor: Colors.yellow[300],
          borderColor: Colors.orange,
          );
      }
    } 
    else {
      toastMessage(
            context: context,
            message: "Please enter a valid phone number.",
            leadingIcon: const Icon(Icons.error),
            toastColor: Colors.red[200],
            borderColor: Colors.red,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(label: "Emergency"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Call Your Favourite Person', style: TextStyle(fontSize: 27,color: blueColor, fontWeight: FontWeight.bold),),
              Center(
                child: Image.asset(
                  "assets/call/fav_screen.jpg",
                  width: 300,
                  height: 280,
                ),
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.0), 
                      border: Border.all(
                        color: Colors.grey, 
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/call/india_flag.jpg",
                          width: 30,
                          height: 50,
                        ),
                        const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
              // Phone Number Input
              Expanded(
                child: CustomTextFormField(
                  label: "Phone Number",
                  hinttext: "Enter Phone Number", 
                  controller: phoneController, 
                  prefixicon: Icons.call,
                  keyboard: TextInputType.number,
                ),
              ),
              ]
            ),
            
              const SizedBox(height: 16),
              
              // Call Button
              CustomElevatedButton(
                text: "Call",
                onPressed: _makeCall,
                )
            ],
          ),
        ),
      ),
    );
  }
}