import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat_app/controller/theme_controller.dart';
import 'package:my_chat_app/controller/user_controller.dart';
import 'package:my_chat_app/screens/profiles/profile_page.dart';
import 'package:my_chat_app/services/remote_services.dart';
import 'package:my_chat_app/tabs/call_tab.dart';
import 'package:my_chat_app/tabs/chat_tab.dart';
import 'package:my_chat_app/tabs/status_tab.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ThemeController themeController = Get.find<ThemeController>();
  late final Stream<QuerySnapshot> _usersStream;
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();

    if (userController.profileImageUrl == null) {
      fetchUserImageUrl().then((url) {
        if (url != null && mounted) {
          userController.setProfileImageUrl(url);
          precacheImage(CachedNetworkImageProvider(url), context);
        }
      });
    }
    // FirebaseAuth.instance.authStateChanges().listen((user) async {
    //   if (user != null) {
    //   String? token = await user.getIdToken();
    //   print("User token: $token");
    // } else {
    //   print("No user is currently logged in.");
    // }

    // });
  }

  Widget _tab(String text, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.purple[800] : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;

    return Scaffold(
      backgroundColor: Colors.purple[800],
      body: CustomScrollView(
        slivers: [
          /// APP BAR
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: Colors.purple[800],
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 45, 20, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.menu, color: Colors.white),
                        const Text(
                          'Chatterly',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ProfilePage()),
                            );
                          },
                          child: GetBuilder<UserController>(
                            builder: (controller) => CircleAvatar(
                              child: controller.profileImageUrl == null
                                  ? Icon(Icons.person, color: Colors.white)
                                  : ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: controller.profileImageUrl!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Icons.person,
                                              color: Colors.purple,
                                            ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tab('Chat', 0),
                        _tab('Status', 1),
                        _tab('Calls', 2),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // TABS
          if (_selectedIndex == 0) ...[
            ChatTab(currentUser: widget.user, usersStream: _usersStream),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(color: bgColor),
            ),
          ],

          if (_selectedIndex == 1) ...[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(color: bgColor, child: const StatusTab()),
            ),
          ],

          if (_selectedIndex == 2) ...[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(color: bgColor, child: const CallTab()),
            ),
          ],
        ],
      ),
    );
  }
}
