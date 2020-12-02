import 'package:cached_network_image/cached_network_image.dart';
import 'package:coocoo/NewScreens/friend_profile_screen.dart';
import 'package:coocoo/blocs/chats/chat_bloc.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/stateProviders/mqtt_state.dart';
import 'package:coocoo/stateProviders/profilePicUrlState.dart';
import 'package:coocoo/widgets/ImageFullScreenWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart' as emj;
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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

  Widget _buildSendButton(double algo) {
    return Expanded(
      child: InkWell(
        onTap: () {
          String tempChatId = widget.toContact.chatId;
          String msgToSend = parser.unemojify(chatTextController.text);

          chatBloc.add(SendMessageEvent(context, msgToSend, tempChatId));
          // userDataFunction.sendNotification(
          //   toUid: widget.toContact.phoneNumber,
          //   title: "You have New Messages",
          //   content: "Click To View",
          // );
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

  Widget _buildLeftPicture(double algo) {
    final String myProfileUrl =
        context.watch<ProfilePicUrlState>().profilePicUrl;
    return GestureDetector(
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
            radius: algo * 23.5,
            backgroundImage: CachedNetworkImageProvider(myProfileUrl),
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
  }

  @override
  void dispose() {
    chatTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double algo = screenWidth / perfectWidth;
    return Scaffold(
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
            _buildLeftPicture(algo),
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
              // pickImage();
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
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              child: Text("GET MSGS"),
              onPressed: () {},
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
}
