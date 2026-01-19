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
      if (!mounted) return;
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
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Post New Gig',
            style: TextStyle(
                color: Color(0xFF2D3447), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  _toggleBtn('Quick Task', _selectedType == 'Quick Task',
                      () => setState(() => _selectedType = 'Quick Task')),
                  _toggleBtn(
                      'Skilled Project',
                      _selectedType == 'Skilled Project',
                      () => setState(() => _selectedType = 'Skilled Project')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _inputField(_titleController, 'Job Title', Icons.title_rounded),
            const SizedBox(height: 16),
            _inputField(
                _budgetController, 'Budget (₹)', Icons.currency_rupee_rounded,
                isNumber: true),
            const SizedBox(height: 16),
            _inputField(
                _descController, 'Description', Icons.description_rounded,
                maxLines: 5),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postGig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E54C8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFF4E54C8).withOpacity(0.4),
                ),
                child: _isPosting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Gig',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4E54C8) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
              child: Text(text,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _inputField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)
          ]),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
