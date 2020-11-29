import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coocoo/NewScreens/friend_profile_screen.dart';
import 'package:coocoo/blocs/chats/chat_bloc.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/models/ChatMessage.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/stateProviders/mqtt_state.dart';
import 'package:coocoo/stateProviders/profilePicUrlState.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:coocoo/widgets/GradientSnackBar.dart';
import 'package:coocoo/widgets/ImageFullScreenWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart' as emj;
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final MyContact toContact;

  ChatScreen(this.toContact);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  String loggedInUser;
  TextEditingController chatTextController = TextEditingController();
  ChatBloc chatBloc;
  double _scale;
  AnimationController _loveController;
  final picker = ImagePicker();
  var parser = emj.EmojiParser();
  UserDataFunction userDataFunction = UserDataFunction();
  final String myUid = SharedObjects.prefs.getString(Constants.sessionUid);

  ChatMessage chatMessage = ChatMessage.fromMap({
    "msg": " ",
    "time": 0,
    "msgType": "text",
    "chatId": "ab",
  });

  Future<void> getCurrentUser() async {
    FirebaseUser currUser = await _auth.currentUser();
    loggedInUser = currUser.phoneNumber.substring(3);
  }

  Widget _buildLeftPicture(double algo) {
    final String myProfileUrl =
        context.watch<ProfilePicUrlState>().profilePicUrl;
    return Expanded(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ImageFullScreen(myProfileUrl, tag: "myProfile")));
            },
            child: Hero(
              tag: 'myProfile',
              child: Neumorphic(
                style: kCircleNeumorphicStyle,
                child: CircleAvatar(
                  radius: algo * 28.5,
                  backgroundImage: CachedNetworkImageProvider(myProfileUrl),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPicture(double algo) {
    final String contactProfileUrl = widget.toContact.photoUrl;
    return Expanded(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageFullScreen(
                            contactProfileUrl,
                            tag: 'dash${widget.toContact.ind}',
                          )));
            },
            child: Hero(
              tag: 'dash${widget.toContact.ind}',
              child: Neumorphic(
                style: kCircleNeumorphicStyle,
                child: CircleAvatar(
                  radius: algo * 29.0,
                  backgroundImage:
                      CachedNetworkImageProvider(contactProfileUrl),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoveButton(double algo) {
    return GestureDetector(
      onTapDown: _onLoveTapDown,
      onTapUp: _onLoveTapUp,
      child: Transform.scale(
        scale: _scale,
        child: Neumorphic(
          style: kChatCircleNeumorphicStyle,
          child: CircleAvatar(
            radius: algo * 30.0,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.favorite,
              size: algo * 45.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _onLoveTapDown(TapDownDetails details) {
    _loveController.forward();
    chatBloc.add(SendMessageEvent(
      context,
      "black_heart",
      widget.toContact.chatId,
    ));
    userDataFunction.sendNotification(
      toUid: widget.toContact.phoneNumber,
      title: "You have New Messages",
      content: "Click To View",
    );
  }

  void _onLoveTapUp(TapUpDetails details) {
    _loveController.reverse();
  }

  Widget _buildSendButton(double algo) {
    return Expanded(
      child: InkWell(
        onTap: () {
          String tempChatId = widget.toContact.chatId;
          String msgToSend = parser.unemojify(chatTextController.text);

          // get the last sender and last message for that particular chatId
          String lastSender =
              context.read<MQTTState>().getLastSender(tempChatId);
          String lastMsg = context.read<MQTTState>().getLastMsg(tempChatId);

          if (lastMsg != 'black_heart') {
            if (myUid == lastSender) {
              msgToSend = lastMsg + '\n\n' + msgToSend;
              print(msgToSend);
            }
          }

          chatBloc.add(SendMessageEvent(context, msgToSend, tempChatId));
          userDataFunction.sendNotification(
            toUid: widget.toContact.phoneNumber,
            title: "You have New Messages",
            content: "Click To View",
          );
          chatTextController.clear();
        },
        child: Neumorphic(
          style: kCircleNeumorphicStyle,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: algo * 33.0,
            child: Neumorphic(
              style: NeumorphicStyle(
                shadowDarkColor: Colors.blueGrey,
                boxShape: NeumorphicBoxShape.circle(),
                depth: 4,
                intensity: 0.7,
                surfaceIntensity: 0.6,
              ),
              child: CircleAvatar(
                radius: algo * 23.0,
                backgroundColor: Colors.white,
                child:
                    Icon(Icons.send, color: Colors.blueGrey, size: algo * 26.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeMessageTextField() {
    return Expanded(
      flex: 5,
      child: Row(
        children: [
          Expanded(
            child: Neumorphic(
              margin: EdgeInsets.only(left: 6, right: 5, top: 2, bottom: 4),
              style: NeumorphicStyle(
                depth: -15,
                boxShape: NeumorphicBoxShape.stadium(),
                shadowDarkColorEmboss: Colors.black,
                shadowLightColor: Colors.white,
                intensity: 0.6,
              ),
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              child: TextField(
                cursorColor: Colors.blueGrey,
                controller: chatTextController,
                style: TextStyle(
                  fontSize: 21.0,
                ),
                decoration:
                    InputDecoration.collapsed(hintText: "Type a message"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createMessage({TextStyle msgTextStyle, Size screenSize}) {
    print(chatMessage.msgType);
    if (chatMessage.msgType == 'text' || chatMessage.msgType == null) {
      return chatMessage.msg != 'black_heart'
          ? Text(
              parser.emojify("${chatMessage.msg ?? ''}\n"),
              style: msgTextStyle,
            )
          : Icon(
              Icons.favorite,
              size: 55.0,
              color: Colors.black,
            );
    } else {
      try {
        return Image(
          image: MemoryImage(base64Decode(chatMessage.msg)),
          height: screenSize.height / 2.5,
          width: screenSize.width / 2,
        );
      } catch (e) {
        return Image(
          image: AssetImage('images/user.png'),
          height: screenSize.height / 2.5,
          width: screenSize.width / 2,
        );
      }
    }
  }

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File tempFile = File(pickedFile.path);
      chatBloc.add(SendImageEvent(context, tempFile, widget.toContact.chatId));
      GradientSnackBar.showMessage(
          context, "Sending Your Beautiful Image...", 4);
      userDataFunction.sendNotification(
        toUid: widget.toContact.phoneNumber,
        title: "You have New Messages",
        content: "Click To View",
      );
    }
  }

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    super.initState();
    chatBloc.add(LoadInitialMessagesEvent(widget.toContact.chatId));
    _loveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.25,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _loveController.dispose();
    chatTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _loveController.value;
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double algo = screenWidth / perfectWidth;
    final TextStyle kmsgTextStyle =
        Theme.of(context).textTheme.headline6.copyWith(
              fontSize: algo * 19.5,
              letterSpacing: 0.1,
            );
    final TextStyle kTimeTextStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: algo * 12.0,
            );

    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blueGrey[700],
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FriendProfileScreen(widget.toContact)));
            },
            child: Text(
              widget.toContact.name,
              style: TextStyle(
                color: Colors.blueGrey[700],
                fontSize: algo * 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                pickImage();
              },
              child: Icon(
                Icons.attach_file,
                color: Colors.blueGrey[700],
                size: 30.0,
              ),
            ),
            SizedBox(width: algo * 15.0),
          ],
        ),
        body: Padding(
          padding:
              EdgeInsets.only(bottom: 7.0, left: 2.0, right: 2.0, top: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildLeftPicture(algo),
                          Expanded(
                            flex: 5,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 4,
                                  child: BlocListener<ChatBloc, ChatState>(
                                    listener: (context, state) {
                                      if (state is ReceivedMessageState) {
                                        if (state.chatMessage.chatId ==
                                            widget.toContact.chatId) {
                                          setState(() {
                                            chatMessage = state.chatMessage;
                                          });
                                        }
                                      }

                                      if (state is InitialMessagesLoadedState) {
                                        setState(() {
                                          chatMessage = state.chatMessage;
                                        });
                                      }
                                    },
                                    child: Stack(
                                      fit: StackFit.passthrough,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 22.0),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 6.0),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blueGrey,
                                                  offset:
                                                      Offset(2.5, 3.5), //(x,y)
                                                  blurRadius: 2.5,
                                                ),
                                              ],
                                              color: Colors.blueGrey[100],
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20.0),
                                                bottomLeft:
                                                    Radius.circular(20.0),
                                              ),
                                            ),
                                            child: createMessage(
                                                msgTextStyle: kmsgTextStyle,
                                                screenSize: screenSize),
                                          ),
                                        ),
                                        Positioned(
                                          right: 5.0,
                                          bottom: 26.0,
                                          child: Text(
                                            chatMessage.time != null
                                                ? DateFormat()
                                                    .add_MMMd()
                                                    .add_jm()
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            chatMessage.time))
                                                : "",
                                            style: kTimeTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _buildRightPicture(algo),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ), // containing the chats thing
              Column(
                children: [
                  _buildLoveButton(algo),
                  Row(
                    children: <Widget>[
                      _buildTypeMessageTextField(),
                      _buildSendButton(algo),
                    ],
                  ),
                ],
              ), // containing love button and textfield
            ],
          ),
        ));
  }
}

// TODO: Add Online/Offline Functionality
