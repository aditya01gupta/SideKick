import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicantsScreen extends StatelessWidget {
  final String gigId;
  final String gigTitle;
  const ApplicantsScreen(
      {super.key, required this.gigId, required this.gigTitle});

  Future<void> _hireAndPay(String appId, String studentId, int amount) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(appId)
        .update({'status': 'Paid'});
    await FirebaseFirestore.instance.collection('users').doc(studentId).update({
      'balance': FieldValue.increment(amount),
      'completedGigs': FieldValue.increment(1),
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .collection('transactions')
        .add({'title': gigTitle, 'amount': amount, 'date': Timestamp.now()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Applicants: $gigTitle")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('gigId', isEqualTo: gigId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var app = snapshot.data!.docs[index];
              return ListTile(
                title: Text(app['applicantEmail']),
                subtitle: Text("Status: ${app['status']}"),
                trailing: app['status'] == 'Pending'
                    ? ElevatedButton(
                        onPressed: () =>
                            _hireAndPay(app.id, app['applicantId'], app['pay']),
                        child: const Text("Pay"))
                    : const Icon(Icons.check, color: Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}
