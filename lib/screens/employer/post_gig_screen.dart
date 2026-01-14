import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostGigScreen extends StatefulWidget {
  const PostGigScreen({super.key});

  @override
  State<PostGigScreen> createState() => _PostGigScreenState();
}

class _PostGigScreenState extends State<PostGigScreen> {
  String _selectedType = 'Quick Task';
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descController = TextEditingController();
  bool _isPosting = false;

  Future<void> _postGig() async {
    if (_titleController.text.isEmpty || _budgetController.text.isEmpty) return;
    setState(() => _isPosting = true);
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance.collection('gigs').add({
        'title': _titleController.text.trim(),
        'pay': int.tryParse(_budgetController.text) ?? 0,
        'description': _descController.text.trim(),
        'type': _selectedType,
        'employerId': user?.uid,
        'postedBy': user?.email,
        'createdAt': Timestamp.now(),
        'status': 'Active',
        'applicantCount': 0,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gig Posted!'), backgroundColor: Colors.green));
      _titleController.clear();
      _budgetController.clear();
      _descController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              const Text('Post New Gig', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigo),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildTypeSelector('Quick Task', Icons.flash_on)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTypeSelector(
                        'Skilled Project', Icons.workspace_premium)),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: 'Job Title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Budget (₹)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(
                controller: _descController,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: 'Description',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 32),
            SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    onPressed: _isPosting ? null : _postGig,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Post Gig',
                        style: TextStyle(color: Colors.white)))),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String type, IconData icon) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? Colors.indigo : Colors.grey.shade300)),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.amber : Colors.grey, size: 30),
            const SizedBox(height: 8),
            Text(type,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
