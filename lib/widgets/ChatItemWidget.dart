import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/models/ChatMessage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatItemWidget extends StatelessWidget {
  final ChatMessage message;

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
          buildMessageContainer(message.isSelf, message.msg, context),
          buildTimeStamp(context, message.isSelf, message.time.toString())
        ],
      ),
    );
  }

  Row buildMessageContainer(bool isSelf, String msgBody, BuildContext context) {
    double lrEdgeInsets = 15.0;
    double tbEdgeInsets = 10.0;

    return Row(
      children: <Widget>[
        Container(
          child: Text(
            msgBody,
            style: TextStyle(
              color: isSelf ? selfMessageColor : otherMessageColor,
              fontSize: 15.0,
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              lrEdgeInsets, tbEdgeInsets, lrEdgeInsets, tbEdgeInsets),
          constraints: BoxConstraints(maxWidth: 400.0),
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
