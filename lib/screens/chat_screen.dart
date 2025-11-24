import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';
import '../messaging/messaging_config.dart';
import '../widgets/message_widget.dart';
import '../services/fcm_service.dart';

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
    registerFCMListeners();
    handleInitialMessage();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) signedUser = user;
  }


  void registerFCMListeners() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      MessagingConfig.showLocalNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final email = message.data['email'];
      if (email != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => ChatScreen(chatWithEmail: email)),
        );
      }
    });

  }



  Future<void> handleInitialMessage() async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data['email'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(chatWithEmail: initialMessage.data['email'])),
      );
    }
  }

  String getChatId(String user1, String user2) =>
      user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';

  void sendMessage() async {
    final text = usermsgController.text.trim();
    if (text.isEmpty || widget.chatWithEmail == null) return;

    final chatId = getChatId(signedUser.email!, widget.chatWithEmail!);
    await _firestore.collection(collectionName).doc(chatId).collection(subCollectionName).add({
      'text': text,
      'sender': signedUser.email,
      'receiver': widget.chatWithEmail,
      'time': FieldValue.serverTimestamp(),
    });

    usermsgController.clear();
    setState(() {});

    final snap = await _firestore.collection('users').where('email', isEqualTo: widget.chatWithEmail).get();
    if (snap.docs.isNotEmpty) {
      final token = snap.docs.first['token'];
      await sendFCMNotification(
        token: token,
        title: signedUser.email!,
        body: text,
        data: {'email': signedUser.email!},
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(signedUser.email ?? '', widget.chatWithEmail ?? '');
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatWithEmail ?? "Chat"), backgroundColor: Colors.yellow[800]!),
      body: Column(
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
                    decoration: const InputDecoration(hintText: 'Write Message...', border: InputBorder.none),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.orange), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
