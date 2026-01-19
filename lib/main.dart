import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file exists
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SideKickApp());
}

class SideKickApp extends StatelessWidget {
  const SideKickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SideKick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFFF0F2F5), // Soft grey background
        primaryColor: const Color(0xFF2D3447), // Deep Navy
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E54C8), // Electric Blue
          secondary: const Color(0xFFFF6B6B), // Coral Red accent
        ),
        fontFamily:
            'Roboto', // Or GoogleFonts.poppins() if you add google_fonts
        cardTheme: CardTheme(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
