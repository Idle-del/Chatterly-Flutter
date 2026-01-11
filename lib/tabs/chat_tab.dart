import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/screens/chat_screen.dart';

class ChatTab extends StatelessWidget {
  final User currentUser;
  final Stream<QuerySnapshot> usersStream;

  const ChatTab({
    super.key,
    required this.currentUser,
    required this.usersStream,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;

    return StreamBuilder<QuerySnapshot>(
      stream: usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: backgroundColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: backgroundColor,
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: backgroundColor,
              child: const Center(child: Text('No users found')),
            ),
          );
        }

        final users = snapshot.data!.docs
            .where((doc) => doc.id != currentUser.uid)
            .toList();

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final userData = users[index].data() as Map<String, dynamic>;

            return Container(
              margin: EdgeInsets.only(top: index == 0 ? 20 : 0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: index == 0
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )
                    : null,
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(userData['username'] ?? ''),
                subtitle: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(
                        currentUser.uid.compareTo(users[index].id) > 0
                            ? '${currentUser.uid}_${users[index].id}'
                            : '${users[index].id}_${currentUser.uid}',
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text('Say hi 👋');
                    }
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final lastMessageSenderId = data['lastMessageSenderId'];
                    final lastMessage = data['lastMessage'];
                    if (lastMessage is! String || lastMessage.trim().isEmpty) {
                      return const Text('Say hi 👋');
                    }
                    bool isMe = lastMessageSenderId == currentUser.uid;
                    return Text(
                      isMe ? 'You: $lastMessage' : lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      myId: currentUser.uid,
                      otherId: users[index].id,
                      otherName: userData['username'] ?? '',
                    ),
                  ),
                ),
              ),
            );
          }, childCount: users.length),
        );
      },
    );
  }
}
