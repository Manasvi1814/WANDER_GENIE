import 'package:flutter/material.dart';
// import 'screens/wander_genie_screen.dart';
// import 'screens/login_screen.dart';
import 'screens/third_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wander Genie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8D4B38)),
        useMaterial3: true,
        // You can uncomment the font family line if you add a serif font to your assets
        // fontFamily: 'Serif', 
      ),
      // // To preview other screens, change the home widget below:
      // home: const LoginScreen(),
      home: const ThirdScreen(),
      // home: const WanderGenieScreen(),
    );
  }
}
