import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navigaurd/screens/feed_sub_screens/dash_cam.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/app/app_provider.dart';
import 'package:navigaurd/screens/home/home.dart';

void main() async{
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
        // home: const AccidentReportScreen(coordinates: LatLng(16.568821984802113, 81.52605148094995)),
        // home: CustomSplashScreen(),
        home: HomeScreen(),
        // home: ImageUploader(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

