// ignore_for_file: use_build_context_synchronously, sort_child_properties_last
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat_app/controller/theme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_chat_app/screens/profile_edit.dart';
import 'package:my_chat_app/screens/start_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _userinfo = FirebaseFirestore.instance.collection('users');

  // Logout function
  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StartScreen()),
      (route) => false,
    );
  }

  Padding _menu(IconData icon, String text, VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: Icon(icon, color: isDark ? Colors.white : Colors.black),
          title: Text(text),
          onTap: onTap,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey[900]! : Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Center(
            child: const Text(
              "Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          actions: [
            GetBuilder<ThemeController>(
              builder: (controller) {
                return IconButton(
                  onPressed: () {
                    controller.toggleTheme();
                  },
                  icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                children: [
                  SizedBox(height: 50),

                  CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: _userinfo
                        .where('uid', isEqualTo: _auth.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No user data found'));
                      }
                      final userData =
                          snapshot.data!.docs.first.data()
                              as Map<String, dynamic>;
                      return Column(
                        children: [
                          Text(
                            userData['username'] ?? '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            userData['email'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if ((userData['bio'] ?? '').isNotEmpty)
                            Text(
                              userData['bio'],
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),

                          const SizedBox(height: 25),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(180, 50),
                              backgroundColor: Colors.purple[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ProfileEdit()),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _menu(Icons.settings, "Settings", () {}, isDark),
                          _menu(
                            Icons.credit_card,
                            "Billing Details",
                            () {},
                            isDark,
                          ),
                          _menu(Icons.group, "User Management", () {}, isDark),
                          _menu(
                            Icons.info_outline,
                            "Information",
                            () {},
                            isDark,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout button at bottom right
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _logout,
                backgroundColor: Colors.redAccent,
                child: Icon(
                  Icons.logout,
                  color: isDark ? Colors.black : Colors.white,
                ),
                tooltip: 'Logout',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
