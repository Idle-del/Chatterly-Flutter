// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_chat_app/controller/user_controller.dart';
import 'package:my_chat_app/screens/profiles/view_profile.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _bioFocusNode = FocusNode();
  final user = FirebaseAuth.instance.currentUser!;

  final userController = Get.find<UserController>();

  bool isEditingName = false;
  bool isEditingBio = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = user.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!mounted) return;
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        setState(() {
          _fullNameController.text = userData['username'] ?? '';
          _bioController.text = userData['bio'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showProfileOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return userController.profileImageUrl != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.visibility),
                    title: const Text('View profile picture'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewProfileImage(
                            imageUrl: userController.profileImageUrl!,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Update profile picture'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Add profile picture'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SafeArea(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        // const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 100),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        GestureDetector(
                          onTap: () => showProfileOptions(context, isDark),
                          child: GetBuilder<UserController>(
                            builder: (controller) => CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  controller.profileImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      controller.profileImageUrl!,
                                    )
                                  : null,
                              child: controller.profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _editField(
                                label: 'Full Name',
                                controller: _fullNameController,
                                isEditing: isEditingName,
                                isDark: isDark,
                                focusNode: _fullNameFocusNode,
                                onEditChanged: () {
                                  setState(() {
                                    isEditingName = !isEditingName;
                                  });

                                  if (isEditingName) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          _fullNameFocusNode.requestFocus();
                                        });
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .update({
                                          'username': _fullNameController.text,
                                        });
                                  }
                                  FocusScope.of(context).unfocus();
                                },
                              ),

                              const Divider(),

                              const SizedBox(height: 20),

                              _editField(
                                label: 'Bio',
                                controller: _bioController,
                                isEditing: isEditingBio,
                                isDark: isDark,
                                maxLines: 3,
                                focusNode: _bioFocusNode,
                                onEditChanged: () {
                                  setState(() {
                                    isEditingBio = !isEditingBio;
                                  });

                                  if (isEditingBio) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          _bioFocusNode.requestFocus();
                                        });
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .update({'bio': _bioController.text});
                                  }
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

Widget _editField({
  required String label,
  required TextEditingController controller,
  required bool isEditing,
  required VoidCallback onEditChanged,
  required bool isDark,
  int minLines = 1,
  int maxLines = 1,
  FocusNode? focusNode,
}) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: maxLines,
                minLines: minLines,
                focusNode: focusNode,
                readOnly: !isEditing,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: onEditChanged,
          icon: Icon(
            isEditing ? Icons.check : Icons.edit,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    ),
  );
}
