import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicantsScreen extends StatelessWidget {
  final String gigId;
  final String gigTitle;
  const ApplicantsScreen(
      {super.key, required this.gigId, required this.gigTitle});

  Future<void> _hireAndPay(BuildContext context, String appId, String studentId,
      int payAmount) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(appId)
          .update({'status': 'Hired & Paid'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .update({
        'balance': FieldValue.increment(payAmount),
        'completedGigs': FieldValue.increment(1),
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .collection('transactions')
          .add({
        'title': gigTitle,
        'amount': payAmount,
        'date': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Student Paid!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Applicants: $gigTitle'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('gigId', isEqualTo: gigId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final apps = snapshot.data!.docs;
          if (apps.isEmpty)
            return const Center(child: Text('No applicants yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(app['applicantEmail'] ?? ''),
                  subtitle: Text('Status: ${app['status']}'),
                  trailing: app['status'] == 'Pending'
                      ? ElevatedButton(
                          onPressed: () => _hireAndPay(context, apps[index].id,
                              app['applicantId'], app['pay']),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text('Pay',
                              style: TextStyle(color: Colors.white)),
                        )
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
