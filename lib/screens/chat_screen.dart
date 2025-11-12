import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../widgets/message_widget.dart';

final _firestore = FirebaseFirestore.instance;
const String collectionName = 'chats';
const String subCollectionName = 'messages';
late User signedUser;

class ChatScreen extends StatefulWidget {
  static const String id = '/chat_screen';
  final String? chatWithEmail;
  const ChatScreen({super.key, this.chatWithEmail});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController usermsgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      signedUser = user;
      print('Signed in as: ${signedUser.email}');
    }
  }
 //
  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }

  void sendMessage() async {
    final text = usermsgController.text.trim();
    if (text.isEmpty || widget.chatWithEmail == null) return;

    final chatId = getChatId(signedUser.email!, widget.chatWithEmail!);

    await _firestore.collection(collectionName)
        .doc(chatId)
        .collection(subCollectionName)
        .add({
      'text': text,
      'sender': signedUser.email,
      'receiver': widget.chatWithEmail,
      'time': FieldValue.serverTimestamp(),
    });

    usermsgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(signedUser.email ?? '', widget.chatWithEmail ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatWithEmail ?? "Chat"),
        backgroundColor: Colors.yellow[800]!,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MessageStreamBuilder(
                firebaseQuery: _firestore
                    .collection(collectionName)
                    .doc(chatId)
                    .collection(subCollectionName)
                    .orderBy('time', descending: false),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: usermsgController,
                      decoration: const InputDecoration(
                        hintText: 'Write Message ...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.orange),
                    onPressed: sendMessage,
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
