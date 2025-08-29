import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'mobile_auth_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLogin = true; // toggle between sign-in and sign-up
  bool isLoading = false;

  // Sign in with Email + Password
  Future<void> _signInWithEmail() async {
    setState(() => isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if email verified
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        _showError("Please verify your email before signing in.");
        await _auth.signOut();
      } else {
        _goToHome();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Invalid email or password");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Sign up with Email + Password (Send OTP/Verification Email)
  Future<void> _signUpWithEmail() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Send verification email
      await userCred.user?.sendEmailVerification();

      _showError("Verification email sent! Please check your inbox.");
      await _auth.signOut();

      // Switch back to login screen
      setState(() => isLogin = true);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Failed to sign up");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Google Sign-in
  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        _showError("Please verify your Google email before signing in.");
        await _auth.signOut();
      } else {
        _goToHome();
      }
    } catch (e) {
      _showError("Google sign-in failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? "Welcome Back 👋" : "Create Account ✨",
                style:
                const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                isLogin
                    ? "Sign in to continue"
                    : "Sign up with verification",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Sign In / Sign Up button
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: isLogin ? _signInWithEmail : _signUpWithEmail,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(isLogin ? "Sign In" : "Sign Up"),
              ),

              const SizedBox(height: 15),

              // Toggle between login & signup
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Sign In"),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // Google Sign in
              OutlinedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileAuthPage(),)),
                icon: const Icon(Icons.mobile_friendly),
                label: const Text("Sign in with mobile"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
