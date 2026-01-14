import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
          title: const Text("Earnings"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                width: double.infinity,
                color: Colors.indigo.shade50,
                child: Column(
                  children: [
                    const Text("Total Balance", style: TextStyle(fontSize: 18)),
                    Text("₹${data['balance']}",
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo)),
                  ],
                ),
              ),
              const ListTile(
                  title: Text("History",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('transactions')
                      .snapshots(),
                  builder: (context, transSnapshot) {
                    if (!transSnapshot.hasData) return const SizedBox();
                    return ListView.builder(
                      itemCount: transSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var trans = transSnapshot.data!.docs[index];
                        return ListTile(
                          leading:
                              const Icon(Icons.add_circle, color: Colors.green),
                          title: Text(trans['title']),
                          trailing: Text("+₹${trans['amount']}",
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
