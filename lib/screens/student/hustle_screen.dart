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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Pick your Hustle"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white),
      body: Column(
        children: [
          _buildToggle(),
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
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var gig = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(gig['title']),
                        subtitle: Text(gig['description']),
                        trailing: Text('₹${gig['pay']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Row(
      children: [
        Expanded(
            child: TextButton(
                onPressed: () => setState(() => _showQuickTasks = true),
                child: const Text("Quick Tasks"))),
        Expanded(
            child: TextButton(
                onPressed: () => setState(() => _showQuickTasks = false),
                child: const Text("Skilled Projects"))),
      ],
    );
  }
}
