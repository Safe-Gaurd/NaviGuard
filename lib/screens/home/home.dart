import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:navigaurd/screens/chat/community_chat.dart';
import 'package:navigaurd/screens/maps/maps.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/screens/home/feed_screen.dart';
import 'package:navigaurd/screens/profile/user_profile.dart';

class HomeScreen extends StatefulWidget {
  final bool isLoginOrSignUp;
  const HomeScreen({super.key, this.isLoginOrSignUp = false});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late int currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  @override
  void initState() {
    super.initState();
    // Display toast immediately
    if (widget.isLoginOrSignUp) {
      toastMessage(
        context: context,
        message: "Welcome Back!",
        leadingIcon: const Icon(Icons.emoji_emotions),
        position: DelightSnackbarPosition.top,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  void getData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.fetchUser();
  }

  final List<Widget> screens = [
    const FeedScreen(),
    MapScreen(),
    CommunityScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      return userProvider.isLoading
          ? Scaffold(
              backgroundColor: Colors.white,
              body: const Center(
                child: CircularProgressIndicator(
                  color: blueColor,
                ),
              ),
            )
          : Scaffold(
              key: _scaffoldKey,
              body: screens[currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: currentIndex,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.location_on),
                    label: 'Navigation',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message),
                    label: 'Navigation',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_pin),
                    label: 'Profile',
                  ),
                ],
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                iconSize: 30,
                selectedLabelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
    });
  }

}