import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:direct_caller_sim_choice/direct_caller_sim_choice.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:navigaurd/screens/feed_sub_screens/fav_person_call.dart';
import 'package:navigaurd/screens/home/widgets/custom_card_button.dart';
import 'package:navigaurd/screens/widgets/nav_bars/appbar.dart';

class PhoneCallScreen extends StatelessWidget {
  const PhoneCallScreen({super.key});

  Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    var status = await Permission.phone.request();

    if (status.isGranted) {
      DirectCaller().makePhoneCall('$phoneNumber');
    } else {
      toastMessage(
        context: context,
        message: "Phone Call Permission was Denied",
        position: DelightSnackbarPosition.top,
        leadingIcon: const Icon(Icons.message),
        toastColor: Colors.yellow[300],
        borderColor: Colors.orange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(label: "Emergency"),
      body: Center(
        child: SizedBox(
          height: 500,
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            children: [
              CustomCardButton(
                  title: "Ambulance",
                  imagePath: "assets/call/ambulance.jpg",
                  gradient: LinearGradient(
                      colors: [Colors.blue[300]!, Colors.blue[600]!]),
                  onTap: () {
                    makePhoneCall(context, "108");
                  }),
              CustomCardButton(
                title: "Police",
                imagePath: "assets/call/police.jpg",
                onTap: () {
                  makePhoneCall(context, "100");
                },
                gradient: LinearGradient(
                    colors: [Colors.green[300]!, Colors.green[600]!]),
              ),
              CustomCardButton(
                title: "Fire Extinguisher",
                imagePath: "assets/call/firefighter.jpg",
                onTap: () {
                  makePhoneCall(context, "101");
                },
                gradient: LinearGradient(
                    colors: [Colors.red[300]!, Colors.red[600]!]),
              ),
              CustomCardButton(
                title: "Favorite Person",
                imagePath: "assets/call/fav.jpg",
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FavPersonCallScreen()));
                },
                gradient: LinearGradient(
                    colors: [Colors.orange[300]!, Colors.orange[600]!]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
