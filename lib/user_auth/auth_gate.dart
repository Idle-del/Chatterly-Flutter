import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/screens/home_screen.dart';
import 'package:my_chat_app/screens/start_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(),);
        }
        if (snapshot.hasData){
          final user = snapshot.data!;
          return HomeScreen(user: user);
        }
        return StartScreen();
      },
    );
  }
}