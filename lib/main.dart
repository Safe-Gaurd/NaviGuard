import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/feed_sub_screens/old_dash_cam.dart';
import 'package:navigaurd/screens/maps/button.dart';
import 'package:navigaurd/screens/onboarding/onboarding_main.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/app/app_provider.dart';
import 'package:navigaurd/screens/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
// void main(){
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProvider.providers,
      child: MaterialApp(
        title: 'SafeGuard',
        theme: ThemeData().copyWith(
            textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        )),
        // home: ButtonScreen(),
        // home: CustomSplashScreen(),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomeScreen();
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("error will loading the data"),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: blueColor,
                  ),
                );
              }

              return const OnboardingMainScreen();
            }),

        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
