import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'post_gig_screen.dart';
import 'employer_profile_screen.dart';

class EmployerMainScreen extends StatefulWidget {
  const EmployerMainScreen({super.key});

  @override
  State<EmployerMainScreen> createState() => _EmployerMainScreenState();
}

class _EmployerMainScreenState extends State<EmployerMainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const EmployerDashboard(),
    const PostGigScreen(),
    const EmployerProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.indigo,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'My Gigs'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Profile'),
        ],
      ),
    );
  }
}
