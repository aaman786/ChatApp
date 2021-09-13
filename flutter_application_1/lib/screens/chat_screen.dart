import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

final _firestore =
    FirebaseFirestore.instance; // because used in verious Widgets
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? messageText;
  // late String email;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print('ChatScreen() error');
      print(e);
    }
  }

  Future<void> messagesStrem() async {
    try {
      await for (var snapshot
          in _firestore.collection('messages').snapshots()) {
        for (var msg in snapshot.docs) {
          print(msg.data());
          Map a = msg.data();
          print(a['text']);

          // TODO: at 14.44
        }
      }
    } catch (e) {
      print("the exception is: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                print("presseed");
                messagesStrem();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      msgTextController.clear();
                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
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

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        List<MsgBubble> msgBubbles = [];

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue[100],
            ),
          );
        }
        Iterable<QueryDocumentSnapshot<Object?>> documents =
            snapshot.data!.docs.reversed;
        for (var doc in documents) {
          var msgText = doc['text'];
          var msgSender = doc['sender'];

          final currentUser = loggedInUser.email;

          final msgBubble = MsgBubble(
            text: msgText, // gets the listview sticky towards the new msg
            sender: msgSender,
            isMe: currentUser == msgSender,
          );
          msgBubbles.add(msgBubble);
        }
        // if has error

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: msgBubbles,
          ),
        );
      },
    );
  }
}

class MsgBubble extends StatelessWidget {
  MsgBubble({required this.text, required this.sender, required this.isMe});

  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMe
          ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: 20.0, right: 0)
          : EdgeInsets.only(top: 8.0, bottom: 8.0, left: 0, right: 20.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.lightGreenAccent[200]),
          ),
          SizedBox(
            height: 4,
          ),
          Material(
            elevation: 10,
            borderRadius: isMe
                ? BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topLeft: Radius.circular(30))
                : BorderRadius.circular(23),
            color: isMe ? Colors.cyanAccent.shade700 : Colors.blue[600],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                text,
                style: TextStyle(color: Colors.amberAccent[50], fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
