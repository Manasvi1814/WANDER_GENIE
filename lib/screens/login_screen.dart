import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/db_helper.dart';
import 'third_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool firebaseAuthSuccess = false;
    String? firebaseErrorMessage;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebaseAuthSuccess = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'CONFIGURATION_NOT_FOUND' ||
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

    // Always check or create local user record
    final dbHelper = DatabaseHelper();
    final localUser =
        await dbHelper.getUser(email, password) ??
        await dbHelper.getUserByEmail(email);

    if (localUser == null && !firebaseAuthSuccess) {
      // If local user doesn't exist and Firebase Auth failed
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sign in failed:\n${firebaseErrorMessage ?? "User not found."}',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Ensure local user record exists
    await dbHelper.getOrCreateUserByEmail(email, email.split('@').first);

    if (!mounted) return;

    if (!firebaseAuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Signed in locally. Firebase Auth notice:\n$firebaseErrorMessage',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

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
          child: Padding(
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
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue your personalized adventure.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 32),

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

                // Sign In
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
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
                            'Sign In',
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
                          color: Colors.grey,
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
                  child: OutlinedButton(
                    onPressed: () {
                      // Google authentication will be added later.
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'G',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Create account
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                        children: const [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Create Account',
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
}
