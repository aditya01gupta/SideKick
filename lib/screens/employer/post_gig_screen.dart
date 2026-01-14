import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostGigScreen extends StatefulWidget {
  const PostGigScreen({super.key});

  @override
  State<PostGigScreen> createState() => _PostGigScreenState();
}

class _PostGigScreenState extends State<PostGigScreen> {
  final _titleController = TextEditingController();
  final _payController = TextEditingController();
  String _type = 'Quick Task';

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('gigs').add({
      'title': _titleController.text,
      'pay': int.parse(_payController.text),
      'type': _type,
      'employerId': user?.uid,
      'applicantCount': 0,
      'createdAt': Timestamp.now(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post a Gig")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title')),
            TextField(
                controller: _payController,
                decoration: const InputDecoration(labelText: 'Pay (₹)'),
                keyboardType: TextInputType.number),
            DropdownButton<String>(
              value: _type,
              items: ['Quick Task', 'Skilled Project']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _type = val!),
            ),
            ElevatedButton(onPressed: _submit, child: const Text("Post Job")),
          ],
        ),
      ),
    );
  }
}
