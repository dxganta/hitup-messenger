import 'package:cached_network_image/cached_network_image.dart';
import 'package:coocoo/blocs/AddFriends/add_friends_bloc.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/widgets/ImageFullScreenWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FriendRequestCard extends StatelessWidget {
  final MyContact friend;
  final parser = EmojiParser();
  final AddFriendsBloc addFriendsBloc;
  final BuildContext contex;

  FriendRequestCard(this.friend, this.addFriendsBloc, this.contex);

  Future<bool> _showPrompt(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Please Confirm'),
            content: Text(
                'Do you want to decline friend request from ${friend.name} ?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'NO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  addFriendsBloc
                      .add(DeclineFriendRequestEvent(friend.phoneNumber));
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'YES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Card(
      elevation: 5.0,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                addFriendsBloc
                    .add(AcceptFriendRequestEvent(friend.phoneNumber, contex));
              },
              child: Neumorphic(
                style: kCircleNeumorphicStyle.copyWith(
                  depth: 5.0,
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.green[500],
                  child: FaIcon(
                    FontAwesomeIcons.check,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: (screenWidth / perfectWidth) * 20.0),
            GestureDetector(
              onTap: () async {
                await _showPrompt(context);
              },
              child: Neumorphic(
                style: kCircleNeumorphicStyle.copyWith(
                  depth: 5.0,
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: FaIcon(
                    FontAwesomeIcons.times,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
