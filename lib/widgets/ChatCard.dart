import 'package:cached_network_image/cached_network_image.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/models/Conversation.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/screens/chat_screen.dart';
import 'package:coocoo/widgets/ImageFullScreenWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';

class ChatCard extends StatelessWidget {
  final Conversation conversation;
  final int ind;
  final parser = EmojiParser();

  ChatCard(this.conversation, this.ind);

  Widget buildMessage(String msgType, TextStyle chatTextStyle) {
    if (msgType == 'text') {
      return Text(
        parser.emojify(conversation.lastMessage),
        style: chatTextStyle,
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.image,
          color: Colors.blueAccent,
          size: 30.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final TextStyle kChatTextStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: (screenWidth / perfectWidth) * 15.0,
            );
    final TextStyle kTimeTextStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(
              fontWeight: FontWeight.w300,
              fontSize: (screenWidth / perfectWidth) * 13.0,
            );
    final TextStyle kTitleTextStyle =
        Theme.of(context).textTheme.headline6.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: (screenWidth / perfectWidth) * 20.0,
            );
    final currTime = DateFormat()
        .add_MMMd()
        .add_jm()
        .format(DateTime.fromMillisecondsSinceEpoch(conversation.time));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Neumorphic(
        style: NeumorphicStyle(
          shadowDarkColor: Colors.blueGrey,
          lightSource: LightSource.topRight,
          color: Colors.white,
          depth: 4,
          intensity: 0.8,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(MyContact(
                          phoneNumber: conversation.phoneNumber,
                          name: conversation.name,
                          photoUrl: conversation.photoUrl,
                          chatId: conversation.chatId,
                          username: conversation.username,
                          ind: ind,
                        ))));
          },
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageFullScreen(
                          url: conversation.photoUrl, tag: "dash$ind")));
            },
            child: Hero(
              tag: "dash$ind",
              child: Neumorphic(
                style: kChatCircleNeumorphicStyle,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: (screenWidth / perfectWidth) * 28.0,
                  backgroundImage:
                      CachedNetworkImageProvider(conversation.photoUrl),
                ),
              ),
            ),
          ),
          title: Text(
            parser.emojify(conversation.name),
            style: kTitleTextStyle,
          ),
          subtitle: buildMessage(conversation.msgType, kChatTextStyle),
          trailing: Text(
            currTime,
            style: kTimeTextStyle,
          ),
        ),
      ),
    );
  }
}
