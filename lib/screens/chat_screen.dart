import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getMessageStream() {
    _firestore.collection('messages').snapshots().map((querySnapshot) {
      for (var element in querySnapshot.docs) {
        print(element.data());
      }
      // });
    }).toList();
  }

  void getMessages() async {
    // final messages = await _firestore
    //     .collection('messages')
    //     .doc('84wYyQDjiwZTirGWXCSZ')
    //     .get()
    //     .then((DocumentSnapshot querySnapshot) {
    //   // querySnapshot.docs.forEach((doc) {
    //     if (querySnapshot.exists) {
    //     print('Document data: ${querySnapshot.data()}');
    //   } else {
    //     print('Document does not exist on the database');
    //   }
    //   // });
    // });

    final messages =
        await _firestore.collection('messages').get().then((querySnapshot) {
      for (var element in querySnapshot.docs) {
        print(element.data());
      }
      // });
    });
    // print(messages);
  }

  void getCurrentUser() {
    try {
      if (_auth != null) {
        User? loggedUser = FirebaseAuth.instance.currentUser;
        loggedInUser = loggedUser;
        print(loggedInUser!.email);
        print('Hello');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addUser() {
    messageTextController.clear();
    return _firestore
        .collection('messages')
        .add({
          'text': messageText,
          'sender': loggedInUser!.email,
          'timestamp': FieldValue.serverTimestamp(),
        })
        .then(
          (value) => print("Message Added"),
        )
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
                // getMessageStream();
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: addUser,
                    child: const Text(
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

class MessagesStream extends StatelessWidget {
  MessagesStream({Key? key}) : super(key: key);
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('messages').orderBy('timestamp', descending: false).snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
            // } else if (snapshot.hasData) {
          }
          //IMPLEMENTATION USING COLUMN
          // return Column(
          //   children: snapshot.data!.docs.map((DocumentSnapshot querySnapshot) {
          //     Map<String, dynamic> data =
          //         querySnapshot.data()! as Map<String, dynamic>;
          //     final messageText = data['text'];
          //     final messageSender = data['sender'];

          //     return Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Text('$messageText from $messageSender'),
          //     );
          //   }).toList(),
          // );

          //IMPLEMENTATION USING LISTVIEW
          return Expanded(
            child: ListView(
              reverse: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children:
                  snapshot.data!.docs.reversed.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                // return ListTile(
                //   title: Text(data['text']),
                //   subtitle: Text(data['sender']),
                // );
                final currentUser = loggedInUser!.email;

                return MessageBubble(
                  sender: data['sender'],
                  text: data['text'],
                  isMe: (currentUser == data['sender']),
                );
              }).toList(),
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({Key? key, this.sender, this.text, this.isMe})
      : super(key: key);

  final String? sender;
  final String? text;
  final bool? isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
          crossAxisAlignment:
              isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(sender!,
                style: const TextStyle(fontSize: 12.0, color: Colors.black54)),
            Material(
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(30.0),
                topLeft: isMe!
                    ? const Radius.circular(30.0)
                    : const Radius.circular(0),
                topRight: isMe!
                    ? const Radius.circular(0)
                    : const Radius.circular(30.0),
                bottomRight: const Radius.circular(30.0),
              ),
              elevation: 5.0,
              color: isMe! ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text!,
                  style: TextStyle(
                      fontSize: 15.0,
                      color: isMe! ? Colors.white : Colors.black),
                ),
              ),
            ),
          ]),
    );
  }
}
