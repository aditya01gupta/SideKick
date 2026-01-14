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

  Future<void> _applyForGig(Map<String, dynamic> gig, String gigId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final existing = await FirebaseFirestore.instance
          .collection('applications')
          .where('gigId', isEqualTo: gigId)
          .where('applicantId', isEqualTo: user.uid)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Already applied!')));
        return;
      }

      await FirebaseFirestore.instance.collection('applications').add({
        'gigId': gigId,
        'gigTitle': gig['title'],
        'employerId': gig['employerId'],
        'applicantId': user.uid,
        'applicantEmail': user.email ?? 'Unknown',
        'pay': gig['pay'],
        'status': 'Pending',
        'appliedAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('gigs').doc(gigId).update({
        'applicantCount': FieldValue.increment(1),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Application Sent!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildToggleButtons(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('gigs')
                    .where('type',
                        isEqualTo:
                            _showQuickTasks ? 'Quick Task' : 'Skilled Project')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final gigs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: gigs.length,
                    itemBuilder: (context, index) {
                      final doc = gigs[index];
                      final gig = doc.data() as Map<String, dynamic>;
                      return _showQuickTasks
                          ? _buildQuickTaskItem(gig, doc.id)
                          : _buildSkilledGigItem(gig, doc.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)]),
      ),
      child: const Row(
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Ready to Hustle?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                Text('Pick your next gig',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ])),
          Icon(Icons.bolt, color: Colors.amber, size: 32),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          _toggleBtn('Quick Tasks', _showQuickTasks,
              () => setState(() => _showQuickTasks = true)),
          _toggleBtn('Skill Gigs', !_showQuickTasks,
              () => setState(() => _showQuickTasks = false)),
        ]),
      ),
    );
  }

  Widget _toggleBtn(String title, bool active, VoidCallback onTap) {
    return Expanded(
        child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: active ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
        child: Center(
            child: Text(title,
                style: TextStyle(
                    color: active ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold))),
      ),
    ));
  }

  Widget _buildQuickTaskItem(Map<String, dynamic> task, String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task['title'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('₹${task['pay']}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber)),
          ElevatedButton(
              onPressed: () => _applyForGig(task, id),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child:
                  const Text('Apply', style: TextStyle(color: Colors.white))),
        ]),
      ]),
    );
  }

  Widget _buildSkilledGigItem(Map<String, dynamic> gig, String id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(gig['title'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('₹${gig['pay']}',
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold)),
        trailing: ElevatedButton(
            onPressed: () => _applyForGig(gig, id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('Apply', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
