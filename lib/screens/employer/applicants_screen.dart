import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicantsScreen extends StatelessWidget {
  final String gigId;
  final String gigTitle;
  const ApplicantsScreen(
      {super.key, required this.gigId, required this.gigTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text('Applicants: $gigTitle',
            style: const TextStyle(
                color: Color(0xFF2D3447), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3447)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('gigId', isEqualTo: gigId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty)
            return const Center(child: Text("No applicants yet."));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final app = doc.data() as Map<String, dynamic>;
              return _buildApplicantCard(context, app, doc.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildApplicantCard(
      BuildContext context, Map<String, dynamic> app, String appId) {
    bool isHired = app['status'] == 'Hired';
    bool isCompleted = app['status'] == 'Completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0E5FF),
          child: Text(app['applicantEmail']?[0].toUpperCase() ?? "U",
              style: const TextStyle(
                  color: Color(0xFF4E54C8), fontWeight: FontWeight.bold)),
        ),
        title: Text(app['applicantEmail'] ?? "Unknown",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Status: ${app['status']}",
            style: TextStyle(color: isHired ? Colors.green : Colors.grey)),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: () {
                  if (isHired) {
                    _showReviewDialog(
                        context, app['applicantId'], appId, app['pay']);
                  } else {
                    _showStudentProfile(context, app['applicantId'], appId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isHired ? Colors.amber : const Color(0xFF4E54C8),
                  foregroundColor: Colors.white, // FIX: Forces text to be white
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(isHired ? "Pay & Review" : "View & Hire"),
              ),
      ),
    );
  }

  // --- FEATURE: VIEW PROFILE ---
  void _showStudentProfile(
      BuildContext context, String studentId, String appId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(studentId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final user = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final skills = List.from(user['skills'] ?? ['General']);
            final rating = user['rating'] ?? 0.0;

            return Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Applicant Profile",
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(user['name'] ?? 'Student',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text(" $rating")
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Skills:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: skills
                        .map((s) => Chip(
                            label: Text(s.toString()),
                            backgroundColor: const Color(0xFFF0F5FF)))
                        .toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _hireStudent(context, appId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white, // FIX
                      ),
                      child: const Text("Hire This Student",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- FEATURE: HIRE LOGIC ---
  Future<void> _hireStudent(BuildContext context, String appId) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(appId)
        .update({'status': 'Hired'});
    // Mark gig as Assigned (hides it from other students)
    await FirebaseFirestore.instance
        .collection('gigs')
        .doc(gigId)
        .update({'status': 'Assigned'});
    if (context.mounted) Navigator.pop(context);
  }

  // --- FEATURE: REVIEW & PAY ---
  void _showReviewDialog(
      BuildContext context, String studentId, String appId, int pay) {
    int rating = 5;
    TextEditingController reviewCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Rate & Pay"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Rate the work to release payment:"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30),
                        onPressed: () => setState(() => rating = index + 1),
                      );
                    }),
                  ),
                  TextField(
                      controller: reviewCtrl,
                      decoration: const InputDecoration(
                          hintText: "Optional comment..."))
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    // Update App Status
                    await FirebaseFirestore.instance
                        .collection('applications')
                        .doc(appId)
                        .update({'status': 'Completed'});

                    // Release Payment & Add Review to User
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(studentId)
                        .update({
                      'balance': FieldValue.increment(pay),
                      'completedGigs': FieldValue.increment(1),
                      'rating':
                          rating.toDouble(), // Simple avg logic placeholder
                    });

                    // Add Transaction Record
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(studentId)
                        .collection('transactions')
                        .add({
                      'title': gigTitle,
                      'amount': pay,
                      'date': Timestamp.now()
                    });

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text("Pay ₹$pay & Close"),
                )
              ],
            );
          },
        );
      },
    );
  }
}
