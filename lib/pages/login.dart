import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'register_screen.dart';
import 'consts.dart';
import 'main_screen.dart';
import '../Widget/custom_text_field.dart';
import '../Widget/submit_button.dart';
import 'home_admin.dart';
import 'home_organizer.dart';
import 'forgot_password.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both email and password.'.tr());
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userRole = await _getUserRole(userCredential.user!.uid);
      _navigateBasedOnRole(userRole);
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Login failed. Please try again.'.tr());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc['role']; 
      } else {
        return 'null'; 
      }
    } catch (e) {
      return 'null';
    }
  }

  void _navigateBasedOnRole(String role) {
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin(userRole: 'admin')),
      );
    } else if (role == 'organizer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeOrganizer(userRole: 'organizer')),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: "933945132412-etjtdm16nc4h35grpldqg98369487cnq.apps.googleusercontent.com",
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'role': 'user',
            'uid': uid,
            'email': user.email,
            'name': user.displayName,
            'phone': user.phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        String userRole = await _getUserRole(uid);
        _navigateBasedOnRole(userRole);
      }
    } catch (e) {
      _showSnackBar('Google Sign-In failed. Please try again.'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBackgroundColor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    context.setLocale(Locale('en'));
                  },
                  child: Text("EN", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 25, 
                  child: VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.setLocale(Locale('zh'));
                  },
                  child: Text("中文", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 25, 
                  child: VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                    width: 20,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.setLocale(Locale('th'));
                  },
                  child: Text("ไทย", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ],
      ),
      backgroundColor: appBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModernTitle(),
            const SizedBox(height: 40),
            CustomTextField(label: 'Email'.tr(), textEditingController: emailController),
            CustomTextField(label: 'Password'.tr(), isObscure: true, textEditingController: passwordController),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SubmitButton(text: 'Log In'.tr(), onPressed: _login),
            const SizedBox(height: 10),
            _buildGoogleSignInButton(),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Sign Up'.tr(), style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
              child: Text('Forgot Password?'.tr(), style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      onPressed: _signInWithGoogle,
      style: ElevatedButton.styleFrom(
        backgroundColor: appBackgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Image.asset('assets/images/google_logo.png', height: 24),
      label: Text(
        'Sign in with Google'.tr(),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildModernTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.orangeAccent, Colors.deepOrange, Colors.redAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        "Eventa",
        style: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 4),
            ),
          ],
        ),
      ),
    );
  }
}
