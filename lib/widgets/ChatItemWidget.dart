import 'dart:convert';

import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/models/ChatMessage.dart';
import 'package:coocoo/widgets/ImageFullScreenWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_emoji/flutter_emoji.dart' as emj;

class ChatItemWidget extends StatelessWidget {
  final ChatMessage message;
  final parser = emj.EmojiParser();

  ChatItemWidget(this.message);

  final Color selfMessageColor = Colors.white;
  final Color otherMessageColor = Colors.black;

  final Color selfMessageBackgroundColor = Constants.textStuffColor;
  final Color otherMessageBackgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          buildMessageContainer(
              message.isSelf, message.msg, context, message.msgType),
          buildTimeStamp(context, message.isSelf, message.time.toString())
        ],
      ),
    );
  }

  Widget buildMessageBody(
      String msgBody, String msgType, bool isSelf, BuildContext context) {
    if (msgType == 'text' || msgType == null) {
      return Text(
        parser.emojify("${msgBody ?? ''}"),
        style: TextStyle(
          color: isSelf ? selfMessageColor : otherMessageColor,
          fontSize: 15.0,
        ),
      );
    } else {
      // it is an image
      try {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImageFullScreen(
                          memoryImage: msgBody,
                        )));
          },
          child: Container(
            width: 95.0,
            height: 25.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.play,
                  color: isSelf ? Colors.white : Colors.black,
                  size: 22.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  "Photo",
                  style: TextStyle(
                    color: isSelf ? Colors.white : Colors.black,
                    fontSize: 19.0,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      } catch (e) {
        return Container();
      }
    }
  }

  Row buildMessageContainer(
      bool isSelf, String msgBody, BuildContext context, String msgType) {
    double lrEdgeInsets = 15.0;
    double tbEdgeInsets = 10.0;

    return Row(
      children: <Widget>[
        Container(
          child: buildMessageBody(msgBody, msgType, isSelf, context),
          padding: EdgeInsets.fromLTRB(
              lrEdgeInsets, tbEdgeInsets, lrEdgeInsets, tbEdgeInsets),
          constraints: BoxConstraints(maxWidth: 300.0),
          decoration: BoxDecoration(
              color: isSelf
                  ? selfMessageBackgroundColor
                  : otherMessageBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
                topLeft: isSelf ? Radius.circular(8.0) : Radius.zero,
                topRight: isSelf ? Radius.zero : Radius.circular(8.0),
              ),
              border: Border.all(color: Colors.grey)),
          margin:
              EdgeInsets.only(right: isSelf ? 5.0 : 0, left: isSelf ? 0 : 5.0),
        )
      ],
      mainAxisAlignment: isSelf
          ? MainAxisAlignment.end
          : MainAxisAlignment.start, // aligns the chatitem to right end
    );
  }

  Row buildTimeStamp(BuildContext context, bool isSelf, String timeStamp) {
    final currTime = DateFormat()
        .add_y()
        .add_MMMd()
        .add_jm()
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp)));
    return Row(
        mainAxisAlignment:
            isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              currTime,
              style: Theme.of(context).textTheme.caption,
            ),
            margin: EdgeInsets.only(
                left: isSelf ? 5.0 : 4.0,
                right: isSelf ? 4.0 : 5.0,
                top: 3.0,
                bottom: 6.0),
          )
        ]);
  }
}
