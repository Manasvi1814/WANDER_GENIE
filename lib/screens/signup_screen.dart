import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_constants.dart';
import '../database/db_helper.dart';
import '../models/user.dart' as local_user;
import 'third_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool firebaseAuthSuccess = false;
    String? firebaseErrorMessage;

    // 1. Attempt Firebase Auth Sign Up
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (name.isNotEmpty) {
        await credential.user?.updateDisplayName(name);
      }
      firebaseAuthSuccess = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          firebaseAuthSuccess = true;
        } catch (signInErr) {
          firebaseErrorMessage = signInErr.toString();
        }
      } else if (e.code == 'CONFIGURATION_NOT_FOUND' ||
          (e.message != null &&
              e.message!.contains('CONFIGURATION_NOT_FOUND'))) {
        firebaseErrorMessage =
            'Email/Password auth is disabled in Firebase Console.\n'
            'Please enable "Email/Password" in Firebase Console -> Authentication -> Sign-in method.';
      } else {
        firebaseErrorMessage = e.message ?? e.toString();
      }
    } catch (e) {
      firebaseErrorMessage = e.toString();
    }

    // 2. Always save account in local SQLite database so user can use app offline
    try {
      final user = local_user.User(
        fullName: name,
        email: email,
        password: password,
      );
      await _dbHelper.insertUser(user);
    } catch (_) {
      await _dbHelper.getOrCreateUserByEmail(email, name);
    }

    if (!mounted) return;

    if (firebaseAuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created & authenticated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created locally. Firebase Auth notice:\n${firebaseErrorMessage ?? "Firebase Auth not connected."}',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }

    // Go to Home Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ThirdScreen()),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrown = Color(0xFF8D4B38);
    const Color backgroundColor = Color(0xFFF9F7F2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // App name
                    const Text(
                      'Wander Genie',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: primaryBrown,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Heading
                    const Text(
                      'Begin Your Journey',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Create an account to start your personalized adventure.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 32),

                    // Full Name
                    _buildLabel('Full Name'),

                    _buildTextField(
                      controller: _nameController,
                      hint: 'Elias Thorne',
                    ),

                    const SizedBox(height: 20),

                    // Email
                    _buildLabel('Email Address'),

                    _buildTextField(
                      controller: _emailController,
                      hint: 'elias@wandergenie.com',
                    ),

                    const SizedBox(height: 20),

                    // Password
                    _buildLabel('Password'),

                    _buildTextField(
                      controller: _passwordController,
                      hint: '••••••••',
                      isPassword: true,
                    ),

                    const SizedBox(height: 32),

                    // Create Account
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Google only
                    SizedBox(
                      width: double.infinity,
                      child: _buildSocialButton(
                        'Continue with Google',
                        Icons.g_mobiledata,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Already have account
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                            children: const [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: primaryBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom image
              Image.network(
                AppImages.loginBg,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(height: 100, color: Colors.grey[200]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF0EFEA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return OutlinedButton(
      onPressed: () {
        // Google authentication will be added later.
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 26),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
