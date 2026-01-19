import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProHeader(user), // RESTORED
            _buildStatsGrid(user?.uid), // RESTORED
            _buildSkillsSection(user?.uid), // RESTORED
            const SizedBox(height: 30),
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProHeader(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      color: const Color(0xFF4E54C8), // Deep Blue
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Color(0xFF4E54C8)),
          ),
          const SizedBox(height: 15),
          Text(user?.displayName ?? "Student Name",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const Text("3rd Year • Computer Science",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          // RESTORED: Rating Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 5),
                Text("4.8 (23 reviews)",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid(String? uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _wideStatCard("Total Earned", "₹${data['balance'] ?? 0}",
                  Icons.account_balance_wallet, Colors.green),
              const SizedBox(height: 15),
              _wideStatCard("Completed Gigs", "${data['completedGigs'] ?? 0}",
                  Icons.check_circle, Colors.blue),
              const SizedBox(height: 15),
              // RESTORED: Success Rate
              _wideStatCard(
                  "Success Rate", "95%", Icons.trending_up, Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _wideStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3447))),
            ],
          )
        ],
      ),
    );
  }

  // RESTORED: Skills Section
  Widget _buildSkillsSection(String? uid) {
    // You can fetch this from DB too, using static list for visual match
    final skills = [
      "Graphic Design",
      "Video Editing",
      "Python",
      "Content Writing"
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Skills",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills
                .map((skill) => Chip(
                      label: Text(skill),
                      backgroundColor: const Color(0xFFE0E5FF),
                      labelStyle: const TextStyle(
                          color: Color(0xFF4E54C8),
                          fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide.none),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (c) => const WelcomeScreen()),
              (r) => false);
        },
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            elevation: 0),
      ),
    );
  }
}
