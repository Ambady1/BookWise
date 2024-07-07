import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String chatUserId;
  final String chatUserName;
  final String chatUserProfilePic;

  ChatPage({
    Key? key,
    required this.chatUserId,
    required this.chatUserName,
    required this.chatUserProfilePic,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference _messagesRef =
      FirebaseFirestore.instance.collection('messages');

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String message = _messageController.text.trim();
    _messageController.clear();

    String chatRoomId = _getChatRoomId(currentUserId, widget.chatUserId);

    _messagesRef.doc(chatRoomId).collection('chats').add({
      'senderId': currentUserId,
      'receiverId': widget.chatUserId,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  String _getChatRoomId(String user1, String user2) {
    return user1.compareTo(user2) < 0 ? '$user1' + '_' + '$user2' : '$user2' + '_' + '$user1';
  }

  @override
  Widget build(BuildContext context) {
    String chatRoomId = _getChatRoomId(currentUserId, widget.chatUserId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatUserProfilePic),
            ),
            const SizedBox(width: 10),
            Text(widget.chatUserName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesRef.doc(chatRoomId).collection('chats').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                List<DocumentSnapshot> messageDocs = snapshot.data!.docs;
                messageDocs.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                return ListView.builder(
                  itemCount: messageDocs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> message = messageDocs[index].data() as Map<String, dynamic>;
                    bool isMe = message['senderId'] == currentUserId;

                    return Container(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message'],
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
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
    );
  }
}
