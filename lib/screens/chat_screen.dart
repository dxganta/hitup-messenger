import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coocoo/screens/friend_profile_screen.dart';
import 'package:coocoo/blocs/chats/chat_bloc.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/models/ChatMessage.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/stateProviders/profilePicUrlState.dart';
import 'package:coocoo/widgets/ChatItemWidget.dart';
import 'package:coocoo/widgets/GradientSnackBar.dart';
import 'package:coocoo/widgets/ImageFullScreenWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart' as emj;
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final MyContact toContact;
  ChatScreen(this.toContact);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var parser = emj.EmojiParser();
  TextEditingController chatTextController = TextEditingController();
  ChatBloc chatBloc;
  UserDataFunction userDataFunction = UserDataFunction();
  List<ChatMessage> allMessages = [];
  ScrollController _scrollController;
  final picker = ImagePicker();

  Widget _buildSendButton(double algo) {
    return Expanded(
      child: InkWell(
        onTap: () {
          String tempChatId = widget.toContact.chatId;
          String msgToSend = parser.unemojify(chatTextController.text);

          chatBloc.add(SendMessageEvent(context, msgToSend, tempChatId));
          userDataFunction.sendNotification(
            toUid: widget.toContact.phoneNumber,
            title: "${widget.toContact.name}",
            content: msgToSend,
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
                onTap: () {
                  // scroll to the bottom of the list when keyboard appears
                  Timer(
                      Duration(milliseconds: 200),
                      () => _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeIn));
                },
                focusNode: FocusNode(),
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

  Widget _buildContactProfilePicture(double algo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageFullScreen(
                    url: widget.toContact.photoUrl,
                    tag: 'dash${widget.toContact.ind}')));
      },
      child: Hero(
        tag: 'dash${widget.toContact.ind}',
        child: Neumorphic(
          style: kCircleNeumorphicStyle,
          child: CircleAvatar(
            radius: algo * 23.5,
            backgroundImage:
                CachedNetworkImageProvider(widget.toContact.photoUrl),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(LoadInitialMessagesEvent(widget.toContact.chatId));
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    chatTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double algo = screenWidth / perfectWidth;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        titleSpacing: 0.0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.blueGrey[700],
          ),
        ),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildContactProfilePicture(algo),
            SizedBox(width: algo * 13.0),
            GestureDetector(
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
          ],
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
          SizedBox(width: 5.0),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FriendProfileScreen(widget.toContact)));
            },
            child: Icon(
              Icons.more_vert_sharp,
              size: 30.0,
            ),
          ),
          SizedBox(width: algo * 15.0),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BlocListener<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ReceivedMessageState) {
                    if (state.chatMessages[0].chatId ==
                        widget.toContact.chatId) {
                      setState(() {
                        allMessages = state.chatMessages;
                      });
                    }
                  }
                  if (state is InitialMessagesLoadedState) {
                    setState(() {
                      allMessages = state.chatMessages;
                    });
                  }

                  // jump to the bottom of the screen when a new message arrives
                  // also using a timer because we need to jump to the bottom
                  // only after the new message is updated in the listview
                  Timer(
                      Duration(milliseconds: 600),
                      () => _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeIn));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: algo * 8.0),
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: allMessages.length,
                      itemBuilder: (context, index) {
                        return ChatItemWidget(allMessages[index]);
                      }),
                ),
              ),
            ),
            Row(
              children: [
                _buildTypeMessageTextField(),
                _buildSendButton(algo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File tempFile = File(pickedFile.path);
      chatBloc.add(SendImageEvent(context, tempFile, widget.toContact.chatId));
      GradientSnackBar.showMessage(
          context, "Sending Your Beautiful Image...", 2);
      userDataFunction.sendNotification(
        toUid: widget.toContact.phoneNumber,
        title: "You have New Messages",
        content: "Click To View",
      );
    }
  }
}
