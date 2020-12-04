import 'package:cached_network_image/cached_network_image.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/widgets/ImageFullScreenWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddFriendCard extends StatelessWidget {
  final MyContact friend;
  final Function addFunc;
  final parser = EmojiParser();

  AddFriendCard(this.friend, this.addFunc);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double algo = screenWidth / perfectWidth;
    return Card(
      elevation: 10.0,
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ImageFullScreen(url: friend.photoUrl)));
          },
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: (screenWidth / perfectWidth) * 28.0,
            backgroundImage: CachedNetworkImageProvider(friend.photoUrl),
          ),
        ),
        title: Text(
          parser.emojify(friend.name),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: (screenWidth / perfectWidth) * 17.0,
          ),
        ),
        subtitle: Text(
          '@${friend.username}',
          style: TextStyle(
            fontSize: (screenWidth / perfectWidth) * 14.0,
          ),
        ),
        trailing: GestureDetector(
          onTap: addFunc,
          child: Card(
              elevation: 5.0,
              color: Colors.grey[200],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: algo * 15.0, vertical: algo * 3.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.userPlus,
                      size: algo * 20.0,
                      color: Constants.textStuffColor,
                    ),
                    SizedBox(
                      width: algo * 5.0,
                    ),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constants.textStuffColor,
                        fontSize: 18.0,
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
