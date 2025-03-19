import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/user.dart';
import 'package:savesmart/screens/auth/signup_screen.dart';
import 'package:savesmart/screens/bottom_navigation.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      final userBox = Hive.box<User>('users');
      final settingsBox = Hive.box('settings');
      
      if (userBox.isEmpty) {
        final uuid = const Uuid();
        final user = User(
          id: uuid.v4(),
          name: 'Demo User',
          email: _emailController.text,
          createdDate: DateTime.now(),
        );
        await userBox.add(user);
      }
      
      await settingsBox.put('isLoggedIn', true);
      await settingsBox.put('currentUserEmail', _emailController.text);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Bottom()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff368983), Color(0xff2b6d68)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 60, color: Color(0xff368983)),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your email'
                              : !value.contains('@')
                                  ? 'Please enter a valid email'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your password'
                              : value.length < 6
                                  ? 'Password must be at least 6 characters'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password?', style: TextStyle(color: Color(0xff368983))),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildButton(
                          text: 'Login',
                          isLoading: _isLoading,
                          onPressed: _login,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have an account?', style: TextStyle(color: Colors.grey.shade600)),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                              child: const Text('Sign Up', style: TextStyle(color: Color(0xff368983), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xff368983)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildButton({required String text, required bool isLoading, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity, // Full-width button
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xff368983), Color(0xff2b6d68)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}