import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/screens/chat_screen.dart';
import 'package:my_chat_app/services/remote_services.dart';

class ChatTab extends StatefulWidget {
  final User currentUser;
  final Stream<QuerySnapshot> usersStream;

  const ChatTab({
    super.key,
    required this.currentUser,
    required this.usersStream,
  });

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  static final Map<String, Future<String?>> avatarCache = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;

    return StreamBuilder<QuerySnapshot>(
      stream: widget.usersStream,
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
            .where((doc) => doc.id != widget.currentUser.uid)
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
                leading: FutureBuilder<String?>(
                  future: avatarCache.putIfAbsent(
                    users[index].id,
                    () => fetchPublicUserImageForUid(users[index].id),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      );
                    }
                    return CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        snapshot.data!,
                      ),
                    );
                  },
                ),
                title: Text(userData['username'] ?? ''),
                subtitle: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(
                        widget.currentUser.uid.compareTo(users[index].id) > 0
                            ? '${widget.currentUser.uid}_${users[index].id}'
                            : '${users[index].id}_${widget.currentUser.uid}',
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
                    bool isMe = lastMessageSenderId == widget.currentUser.uid;
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
                      myId: widget.currentUser.uid,
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
