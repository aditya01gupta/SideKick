import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTANT: Ensure you have initialized Firebase in main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WEB CONFIGURATION
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD9euzJ6_cO_41cDhoX8PT6tNXuRTlNliY',
      authDomain: 'sidekick-edd8a.firebaseapp.com',
      projectId: 'sidekick-edd8a',
      storageBucket: 'sidekick-edd8a.firebasestorage.app',
      messagingSenderId: '778883400133',
      appId: '1:778883400133:web:a07fdb31c0b3b042ef8bac',
    ),
  );

  runApp(const SideKickApp());
}

class SideKickApp extends StatelessWidget {
  const SideKickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SideKick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Check if user is already logged in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Simplified logic: Direct to Student Main Screen by default for demo
          // In a real app, you'd check Firestore to see if user is student or employer
          return const MainScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}

// ================== WELCOME SCREEN ==================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch,
                      size: 80, color: Colors.amber),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome to SideKick',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Connect students with opportunities\nEarn while you learn',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                const Text(
                  'I am a...',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                _buildRoleButton(
                  context,
                  'Student',
                  'Find gigs and earn money',
                  Icons.school,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AuthScreen(userType: 'student')),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRoleButton(
                  context,
                  'Employer',
                  'Post gigs and hire talent',
                  Icons.business,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AuthScreen(userType: 'employer')),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.indigo, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}

// ================== AUTH SCREEN (Login/Signup) ==================
class AuthScreen extends StatefulWidget {
  final String userType;
  const AuthScreen({super.key, required this.userType});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submitAuth() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;
      if (_isLogin) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Save user type to Firestore upon registration
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'role': widget.userType,
          'createdAt': Timestamp.now(),
        });
      }

      if (!mounted) return;

      // Navigate based on role
      if (widget.userType == 'student') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EmployerMainScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Auth failed')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.indigo)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLogin
                  ? 'Login as ${widget.userType}'
                  : 'Join as ${widget.userType}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
            const SizedBox(height: 10),
            Text(_isLogin
                ? 'Welcome back!'
                : 'Create an account to get started'),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isLogin ? 'Login' : 'Sign Up',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin
                  ? 'Create new account'
                  : 'I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== STUDENT MAIN SCREEN ==================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HustleScreen(),
    const EarningsScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.rocket_launch, 'Hustle', 0),
                _buildNavItem(Icons.account_balance_wallet, 'Earnings', 1),
                _buildNavItem(Icons.person, 'Profile', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))
            ],
          ],
        ),
      ),
    );
  }
}

// ================== HUSTLE SCREEN (Reads from Firebase) ==================
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
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No gigs available right now!'));
                  }

                  final gigs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: gigs.length,
                    itemBuilder: (context, index) {
                      final gig = gigs[index].data() as Map<String, dynamic>;
                      return _showQuickTasks
                          ? _buildQuickTaskItem(gig)
                          : _buildSkilledGigItem(gig);
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
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ready to Hustle?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Pick your next gig',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.amber, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.notifications, color: Colors.white),
          ),
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
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showQuickTasks = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _showQuickTasks ? Colors.indigo : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('Quick Tasks',
                        style: TextStyle(
                            color: _showQuickTasks
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showQuickTasks = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color:
                        !_showQuickTasks ? Colors.indigo : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('Skill Gigs',
                        style: TextStyle(
                            color: !_showQuickTasks
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(task['title'] ?? 'Untitled',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 12),
            Text(task['description'] ?? '',
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${task['pay']}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber)),
                ElevatedButton(
                  onPressed: () {},
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: const Text('Apply',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkilledGigItem(Map<String, dynamic> gig) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gig['title'] ?? '',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('₹${gig['pay']}',
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 8),
            Text(gig['description'] ?? '',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                maxLines: 2),
            const SizedBox(height: 12),
            Text('Posted by: ${gig['postedBy'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

// ================== EMPLOYER MAIN SCREEN ==================
class EmployerMainScreen extends StatefulWidget {
  const EmployerMainScreen({super.key});

  @override
  State<EmployerMainScreen> createState() => _EmployerMainScreenState();
}

class _EmployerMainScreenState extends State<EmployerMainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const EmployerDashboard(),
    const PostGigScreen(),
    const EmployerProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard, 'Dashboard', 0),
                _buildNavItem(Icons.add_circle, 'Post Job', 1),
                _buildNavItem(Icons.business, 'Company', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))
            ],
          ],
        ),
      ),
    );
  }
}

// ================== EMPLOYER DASHBOARD (Reads User's Gigs) ==================
class EmployerDashboard extends StatelessWidget {
  const EmployerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
          title: const Text('My Posted Gigs',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigo,
          automaticallyImplyLeading: false),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('gigs')
            .where('employerId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(
                child: Text('You haven\'t posted any gigs yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final gig =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gig['title'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Type: ${gig['type']}'),
                    Text('Pay: ₹${gig['pay']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================== POST GIG SCREEN (Writes to Firebase) ==================
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
        'postedBy': user?.email, // In real app, fetch display name
        'createdAt': Timestamp.now(),
        'status': 'Active',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gig Posted Successfully!'),
          backgroundColor: Colors.green));
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
          backgroundColor: Colors.indigo,
          automaticallyImplyLeading: false),
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
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Budget (₹)',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
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
                child: _isPosting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Gig',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
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
              color: isSelected ? Colors.indigo : Colors.grey.shade300),
        ),
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

// ================== OTHER SCREENS (Placeholders) ==================
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text("Earnings (Connect to Firestore User Data)")));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false);
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}

class EmployerProfileScreen extends StatelessWidget {
  const EmployerProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false);
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
