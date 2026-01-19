import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HustleScreen extends StatefulWidget {
  const HustleScreen({super.key});
  @override
  State<HustleScreen> createState() => _HustleScreenState();
}

class _HustleScreenState extends State<HustleScreen> {
  bool _showQuickTasks = true;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          _buildProHeader(),
          _buildToggle(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('gigs')
                  .where('type',
                      isEqualTo:
                          _showQuickTasks ? 'Quick Task' : 'Skilled Project')
                  .where('status', isEqualTo: 'Active') // Only show open gigs
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No active gigs available",
                          style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return _buildProGigCard(
                        doc.data() as Map<String, dynamic>, doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProGigCard(Map<String, dynamic> gig, String gigId) {
    final List<dynamic> skills = gig['skills'] ?? ['General', 'Dedication'];
    final String duration = gig['duration'] ?? 'Flexible';

    return StreamBuilder<QuerySnapshot>(
      // Check if CURRENT user has applied to THIS gig
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('gigId', isEqualTo: gigId)
          .where('applicantId', isEqualTo: userId)
          .snapshots(),
      builder: (context, appSnap) {
        bool isApplied = appSnap.hasData && appSnap.data!.docs.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FF),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(_showQuickTasks ? Icons.bolt : Icons.star,
                          color: const Color(0xFF4E54C8), size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gig['title'] ?? "Untitled",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3447))),
                          const SizedBox(height: 4),
                          Text(gig['employerName'] ?? "Campus Recruiter",
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(gig['description'] ?? "",
                    style:
                        const TextStyle(color: Color(0xFF52575C), height: 1.5)),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("₹${gig['pay']}",
                          style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 15),
                    Icon(Icons.access_time_rounded,
                        size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 5),
                    Text(duration,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: skills
                      .map((s) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF4F6F9),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(s.toString(),
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF52575C))),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isApplied ? null : () => _apply(gig, gigId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E54C8),
                      foregroundColor:
                          Colors.white, // FIX: Forces text to be white
                      disabledBackgroundColor: const Color(0xFFE0E5FF),
                      disabledForegroundColor: const Color(0xFF4E54C8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(isApplied ? "Applied" : "Apply Now",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildProHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 25),
      decoration: const BoxDecoration(
        color: Color(0xFF4E54C8),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ready to Hustle?",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 5),
                  Text("Pick your next gig",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(15)),
                child:
                    const Icon(Icons.notifications_active, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text("5 new gigs today",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _toggleBtn("Quick Tasks", Icons.bolt, _showQuickTasks,
              () => setState(() => _showQuickTasks = true)),
          _toggleBtn("Skill Gigs", Icons.star_border, !_showQuickTasks,
              () => setState(() => _showQuickTasks = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(
      String text, IconData icon, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4E54C8) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: isActive ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(text,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _apply(Map<String, dynamic> gig, String gigId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('applications').add({
      'gigId': gigId,
      'applicantId': user.uid,
      'applicantEmail': user.email ?? "Unknown",
      'pay': gig['pay'],
      'status': 'Pending',
      'appliedAt': Timestamp.now()
    });

    await FirebaseFirestore.instance
        .collection('gigs')
        .doc(gigId)
        .update({'applicantCount': FieldValue.increment(1)});
  }
}
