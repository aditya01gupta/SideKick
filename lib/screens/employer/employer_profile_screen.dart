import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/welcome_screen.dart';

class EmployerProfileScreen extends StatelessWidget {
  const EmployerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final active = data['activeGigs'] ?? 0;
          final completed = data['completedGigs'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(data['name'] ?? 'Company'),
                const SizedBox(height: 20),
                _buildPieChart(active, completed),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _menuTile(Icons.edit_rounded, "Company Details"),
                      _menuTile(Icons.payment_rounded, "Payment Methods"),
                      _menuTile(Icons.help_outline_rounded, "Support"),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const WelcomeScreen()),
                              (r) => false);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 0),
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      child: Column(
        children: [
          const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE0E5FF),
              child: Icon(Icons.business_rounded,
                  size: 40, color: Color(0xFF4E54C8))),
          const SizedBox(height: 15),
          Text(name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3447))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 16, color: Colors.green),
                SizedBox(width: 5),
                Text("Verified Business",
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPieChart(int active, int completed) {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text("Hiring Stats",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: PieChart(
              PieChartData(sectionsSpace: 5, centerSpaceRadius: 40, sections: [
                PieChartSectionData(
                    color: const Color(0xFF4E54C8),
                    value: active.toDouble() + 1,
                    title: 'Active',
                    radius: 50,
                    titleStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                PieChartSectionData(
                    color: Colors.amber,
                    value: completed.toDouble() + 1,
                    title: 'Closed',
                    radius: 50,
                    titleStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4E54C8)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Colors.grey),
      ),
    );
  }
}
