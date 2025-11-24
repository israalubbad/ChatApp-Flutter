import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../screens/chat_screen.dart';

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({super.key, required this.firebaseQuery});

  final Query firebaseQuery;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseQuery.snapshots(),
      builder: (context, snapshot) {
        List<MessageWidget> messagesWidgets = [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(backgroundColor: Colors.orange),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: Text('No Messages', style: TextStyle(color: Colors.grey)),
          );
        }

        final List<QueryDocumentSnapshot<Object?>> messages = snapshot
            .data!
            .docs
            .reversed
            .toList();

        for (var msg in messages) {
          final msgText = msg.get('text') ?? '';
          final msgSender = msg.get('sender') ?? '';
          final Timestamp? timestamp = msg.get('time');
          final msgTime = timestamp != null ? timestamp.toDate() : null;
          final formattedTime = msgTime != null
              ? DateFormat('hh:mm a').format(msgTime)
              : '';
          bool isSenderMe = signedUser.email == msgSender;

          final messageWidget = MessageWidget(
            msgtext: msgText,
            senderEmail: msgSender,
            isSenderMe: isSenderMe,
            msgTime: formattedTime,
          );
          messagesWidgets.add(messageWidget);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.all(12),
            children: messagesWidgets,
          ),
        );
      },
    );
  }
}
class MessageWidget extends StatelessWidget {
  final String senderEmail;
  final String msgtext;
  final bool isSenderMe;
  final String msgTime;

  const MessageWidget({
    super.key,
    required this.msgtext,
    required this.senderEmail,
    required this.isSenderMe,
    required this.msgTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isSenderMe
          ? CrossAxisAlignment.end     // ✔️ رسائلك على اليمين
          : CrossAxisAlignment.start,  // ✔️ رسائل الآخر على اليسار
      children: [
        Text(
          senderEmail,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 2),
        Container(
          constraints: BoxConstraints(maxWidth: 280),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSenderMe
                ? Colors.yellow[800]!   // ✔️ لون رسائلك
                : Colors.blue[700]!,    // ✔️ لون رسائل الآخر
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isSenderMe ? Radius.circular(12) : Radius.zero,
              bottomRight: isSenderMe ? Radius.zero : Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msgtext,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                msgTime,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
