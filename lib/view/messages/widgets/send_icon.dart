import 'package:chat/services/notification_services.dart';
import 'package:chat/view/messages/bloc/messages_bloc.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendIcon extends StatefulWidget {
  const SendIcon({
    Key key,
    @required this.controller,
    @required this.friendId,
  }) : super(key: key);

  final TextEditingController controller;
  final String friendId;

  @override
  State<SendIcon> createState() => _SendIconState();
}

class _SendIconState extends State<SendIcon> {

  String notMsg;
  String name;
  String token;
  String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : " + uid.toString());
    final firestoreInstance = Firestore.instance;
    firestoreInstance.collection("users").document(uid.toString()).get().then((value){
      name = value.data["name"];
      print("My Name : ${name}");
    });
  }

  @override
  void initState() {
    getUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
            top: deviceData.screenHeight * 0.01,
            bottom: deviceData.screenHeight * 0.01,
            right: deviceData.screenWidth * 0.02),
        child: InkResponse(
          child: Icon(
            Icons.send,
            color: kBackgroundButtonColor,
            size: deviceData.screenWidth * 0.065,
          ),
          onTap: () async {
            if (widget.controller.text.trim().isNotEmpty) {
              Firestore.instance.collection('users').document(widget.friendId).get().then((value){
                NotificationService().sendNotification([value.data['tokenId']], notMsg, "${name}");
              });
              BlocProvider.of<MessagesBloc>(context).add(
                  MessageSent(message: widget.controller.text, friendId: widget.friendId));
            }
          },
        ),
      ),
    );
  }
}
