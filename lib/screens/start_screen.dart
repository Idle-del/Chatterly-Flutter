import 'package:flutter/material.dart';
import 'package:my_chat_app/login/signup/login_screen.dart';
import 'package:my_chat_app/login/signup/signup_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});
  Widget buildButton(
    String text,
    VoidCallback onPressed,
    Color color,
    Color backgroundColor,
    Color? borderColor,
  ) {
    return Container(
      width: 250,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          foregroundColor: color,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
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
              Center(
                child: Text(
                  'Welcome to Chatterly',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.purple[200] : Colors.purple[800],
                  ),
                ),
              ),
              SizedBox(height: 80),
              buildButton(
                'LOGIN',
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ),
                isDark ? Colors.purpleAccent : Colors.purple[800]!,
                isDark ? Colors.grey[900]! : Colors.white,
                isDark ? Colors.purpleAccent : Colors.purple[800]!,
              ),
              SizedBox(height: 8),
              buildButton(
                'SIGNUP',
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                ),
                Colors.white,
                Colors.purple[800]!,
                Colors.transparent,
              ),
              SizedBox(height: 175),
              Text(
                'By continuing, you agree to our Terms of Services and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
