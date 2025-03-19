import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/user.dart';
import 'package:savesmart/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userBox = Hive.box<User>('users');
    final settingsBox = Hive.box('settings');
    final currentUserEmail = settingsBox.get('currentUserEmail');
    
    if (currentUserEmail != null) {
      for (int i = 0; i < userBox.length; i++) {
        final user = userBox.getAt(i);
        if (user != null && user.email == currentUserEmail) {
          setState(() {
            _currentUser = user;
            _nameController.text = user.name;
            _emailController.text = user.email;
            _isLoading = false;
          });
          return;
        }
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    _currentUser!.name = _nameController.text;
    await _currentUser!.save();
    
    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Color(0xff368983),
      ),
    );
  }

  Future<void> _signOut() async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('isLoggedIn', false);
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light background
      appBar: AppBar(
        backgroundColor: const Color(0xff368983),
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff368983)))
          : _currentUser == null
              ? _buildNoUserView()
              : _buildProfileView(),
    );
  }

  Widget _buildNoUserView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            "No User Found",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff368983),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Go to Login",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xff368983),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: 16),
                Text(
                  _currentUser!.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentUser!.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isEditing ? _buildEditForm() : _buildProfileInfo(),
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              _currentUser!.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xff368983),
              ),
            ),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Color(0xff368983),
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Account Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff368983),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, "Created On", 
              "${_currentUser!.createdDate.day}/${_currentUser!.createdDate.month}/${_currentUser!.createdDate.year}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff368983), size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person, color: Color(0xff368983)),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email, color: Color(0xff368983)),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = _currentUser!.name;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.grey.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff368983),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text('Sign Out', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
  }
}