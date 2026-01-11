// ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/login/signup/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isUsernameValid = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool validateInputs() {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    bool usernameValid = username.isNotEmpty;
    bool emailValid = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    ).hasMatch(email);
    bool passwordValid = password.length >= 8;
    bool confirmPasswordValid = password == confirmPassword;
    setState(() {
      _isEmailValid = emailValid;
      _isPasswordValid = passwordValid;
      _isConfirmPasswordValid = confirmPasswordValid;
      _isUsernameValid = usernameValid;
    });
    return emailValid && passwordValid && usernameValid && confirmPasswordValid;
  }

  Widget buildTextField(
    String hintText,
    bool? isPassword,
    Icon icon,
    TextEditingController controller,
    bool isValid,
    String errormsg,
    final bool isDark
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isValid ? Colors.purple[500]! : isDark ? Colors.redAccent : Colors.red,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ?? false,
            decoration: InputDecoration(
              prefixIcon: icon,
              hintText: hintText,
              border: InputBorder.none,
            ),
          ),
        ),
        if (!isValid)
          Text(errormsg, style: TextStyle(color: Colors.red, fontSize: 12)),
      ],
    );
  }

  Future<void> _signup() async {
    if (validateInputs()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        User user = userCredential.user!;

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'profilePicture': null,
          'bio': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        if(!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup successful!')));

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } on FirebaseAuthException catch(e){
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
      }
      catch (e) {
        print('Error during signup: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: Column(
            children: [
              SizedBox(height: 100),
              Center(
                child: Image(
                  image: AssetImage('assets/images/chatterly.png'),
                  height: 200,
                  width: 200,
                ),
              ),
              SizedBox(height: 20),

              buildTextField(
                'Username',
                false,
                Icon(Icons.person, color: isDark ? Colors.purpleAccent : Colors.purple[800]),
                _usernameController,
                _isUsernameValid,
                'Please enter a username',
                isDark
              ),
              buildTextField(
                'Email',
                false,
                Icon(Icons.email, color: isDark ? Colors.purpleAccent : Colors.purple[800]),
                _emailController,
                _isEmailValid,
                'Please enter a valid email address',
                isDark
              ),
              buildTextField(
                'Password',
                true,
                Icon(Icons.lock, color: isDark ? Colors.purpleAccent : Colors.purple[800]),
                _passwordController,
                _isPasswordValid,
                'Password must be at least 8 characters long',
                isDark
              ),
              buildTextField(
                'Confirm Password',
                true,
                Icon(Icons.lock, color: isDark ? Colors.purpleAccent : Colors.purple[800]),
                _confirmPasswordController,
                _isConfirmPasswordValid,
                'Passwords do not match',
                isDark
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(250, 50),
                  backgroundColor: Colors.purple[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'SIGNUP',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ),
                child: Text(
                  'have an account? Login',
                  style: TextStyle(color: isDark ? Colors.purpleAccent : Colors.purple[800]),
                ),
              ),
              SizedBox(height: 60),
              Text(
                'Chatterly © 2024',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
