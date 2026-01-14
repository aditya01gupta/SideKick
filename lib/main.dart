import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD9euzJ6_cO_41cDhoX8PT6tNXuRTlNliY',
      authDomain: 'sidekick-edd8a.firebaseapp.com',
      projectId: 'sidekick-edd8a',
      storageBucket: 'sidekick-edd8a.firebasestorage.app',
      messagingSenderId: '778883400133',
      appId: '1:778883400133:web:a07fdb31c0b3b042ef8bac',
    ),
  );
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
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo, secondary: Colors.amber),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
