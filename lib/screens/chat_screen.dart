import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String myId;
  final String otherId;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.myId,
    required this.otherId,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final String chatId;

  // Generate consistent chat ID
  String _getChatId(String id1, String id2) {
    if (id1.compareTo(id2) > 0) {
      return '${id1}_$id2';
    } else {
      return '${id2}_$id1';
    }
  }

  @override
  void initState() {
    super.initState();
    chatId = _getChatId(widget.myId, widget.otherId);
    _ensureChatExists();
  }

  // Ensure chat document exists BEFORE streaming messages
  Future<void> _ensureChatExists() async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    await chatRef.set({
      'participants': [widget.myId, widget.otherId],
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Send message
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Update chat metadata
    await chatRef.set({
      'participants': [widget.myId, widget.otherId],
      'lastMessage': _messageController.text,
      'lastMessageSenderId': widget.myId,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Add message
    await chatRef.collection('messages').add({
      'senderId': widget.myId,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  // Message stream
  Stream<QuerySnapshot> _getMessages() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900]! : Colors.white,
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: GestureDetector(
          child: Row(
            children: [
              CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  widget.otherName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {
              // Video call action
            },
          ),
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              // Voice call action
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Delete') {
                // delete action
              } else if (value == 'block') {
                // block action
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Delete',
                child: Text('Delete Conversation'),
              ),
              const PopupMenuItem(value: 'Block', child: Text('Block')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      backgroundColor: isDark ? Colors.grey[900]! : Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final messages = snapshot.data!.docs;

                  // if (messages.isEmpty) {
                  //   return const Center(child: Text('Say hi 👋'));
                  // }

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg =
                          messages[index].data() as Map<String, dynamic>;
                      final isMe = msg['senderId'] == widget.myId;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: !isMe
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Colors.purple[300]
                                          : Colors.grey[500],
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      msg['message'] ?? '',
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.purple[300]
                                      : Colors.grey[500],
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  msg['message'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                      );
                    },
                  );
                },
              ),
            ),

            // Input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
