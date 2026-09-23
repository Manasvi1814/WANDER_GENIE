import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/wander_genie_screen.dart';
import 'app_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
        useMaterial3: true,
      ),
      home: const WanderGenieScreen(),
    );
  }
}
