import 'package:flutter/material.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative Circles
          Positioned(
              top: -50,
              left: -50,
              child: _circle(150, Colors.white.withOpacity(0.1))),
          Positioned(
              bottom: -50,
              right: -50,
              child: _circle(200, Colors.white.withOpacity(0.1))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Icon(Icons.rocket_launch_rounded,
                      size: 60, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text("Launch Your\nSide Hustle.",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1)),
                  const SizedBox(height: 10),
                  const Text("Connect. Work. Earn.",
                      style: TextStyle(fontSize: 18, color: Colors.white70)),
                  const Spacer(),
                  const Text("I want to...",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 15),
                  _glassButton(
                      context,
                      "Find Work",
                      "I'm a Student",
                      Icons.school_rounded,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) =>
                                  const AuthScreen(userType: 'student')))),
                  const SizedBox(height: 15),
                  _glassButton(
                      context,
                      "Hire Talent",
                      "I'm an Employer",
                      Icons.business_center_rounded,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) =>
                                  const AuthScreen(userType: 'employer')))),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  Widget _glassButton(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2), // Glass effect
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF4E54C8)),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
