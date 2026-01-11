// ignore_for_file: prefer_final_fields, use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/login/signup/signup_screen.dart';
import 'package:my_chat_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool validateInputs() {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    bool emailValid = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    ).hasMatch(email);
    bool passwordValid = password.length >= 8;

    setState(() {
      _isEmailValid = emailValid;
      _isPasswordValid = passwordValid;
    });
    return emailValid && passwordValid;
  }

  Widget buildTextField(
    String hintText,
    bool? isPassword,
    Icon icon,
    TextEditingController controller,
    bool isValid,
    String errormsg,
    bool isDark
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

  Future<void> _login() async {
    if (validateInputs()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        User? user = userCredential.user;

        if (user != null) {
          if (!mounted) return;
          _emailController.clear();
          _passwordController.clear();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login successful!')));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
      } catch (e) {
        print('Login error: $e');
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
              SizedBox(height: 120),
              Center(
                child: Image(
                  image: AssetImage('assets/images/chatterly.png'),
                  height: 200,
                  width: 200,
                ),
              ),
              SizedBox(height: 20),
              buildTextField(
                'Email',
                false,
                Icon(Icons.email, color: isDark ? Colors.purpleAccent : Colors.purple[800]),
                _emailController,
                _isEmailValid,
                'Please enter a valid email address',
                isDark,
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

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(250, 50),
                  backgroundColor: Colors.purple[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'LOGIN',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                ),
                child: Text(
                  'or create an account',
                  style: TextStyle(
                    color: isDark ? Colors.purpleAccent : Colors.purple[800],
                  ),
                ),
              ),
              SizedBox(height: 100),
              Text(
                'Chatterly © 2024',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
