import 'package:cached_network_image/cached_network_image.dart';
import 'package:coocoo/blocs/chats/chat_bloc.dart';
import 'package:coocoo/blocs/home/home_bloc.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/managers/db_manager.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/widgets/DangerCard.dart';
import 'package:coocoo/widgets/ImageFullScreenWidget.dart';
import 'package:coocoo/widgets/ListTileProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FriendProfileScreen extends StatefulWidget {
  final MyContact friend;
  FriendProfileScreen(this.friend);

  @override
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  ChatBloc chatBloc;
  bool isBlocked = false;
  TextEditingController changeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  HomeBloc homeBloc;

  Future<bool> _showPrompt(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title:
                Text('Are you sure you want to block ${widget.friend.name}?'),
            content:
                Text("You won't be able to send or receive any messages from"
                    " ${widget.friend.name}."),
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
                  chatBloc.add(BlockUserEvent(context, widget.friend.chatId));
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

  void updateIsBlocked() async {
    bool temp = await DBManager.db.isBlocked(widget.friend.chatId);
    setState(() {
      isBlocked = temp;
      print(isBlocked);
    });
  }

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    updateIsBlocked();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double algo = screenWidth / perfectWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: algo * 10.0, horizontal: algo * 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ImageFullScreen(url: widget.friend.photoUrl)));
              },
              child: CircleAvatar(
                radius: algo * 120.0,
                backgroundColor: Colors.white,
                backgroundImage:
                    CachedNetworkImageProvider(widget.friend.photoUrl),
              ),
            ),
            Spacer(
              flex: 2,
            ),
            ListTileProfile(
              iconData: FontAwesomeIcons.book,
              title: 'Full Name',
              subTitle: widget.friend.name,
              trailingWidget: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20.0))),
                    builder: (BuildContext context) {
                      return Form(
                        key: _formKey,
                        child: Container(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              top: 10.0,
                              left: 15.0,
                              right: 15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Edit Name',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: algo * 12.0),
                              TextFormField(
                                validator: (value) {
                                  if (value.trim().isEmpty) {
                                    return "Please enter a valid Name";
                                  }
                                  return null;
                                },
                                controller: changeNameController,
                                style: TextStyle(
                                  fontSize: algo * 18.0,
                                ),
                                autocorrect: false,
                                cursorColor: Colors.blueGrey,
                                decoration:
                                    kHitUpIdTextFieldDecoration.copyWith(
                                  hintText: 'New Name',
                                ),
                              ),
                              SizedBox(height: algo * 8.0),
                              FlatButton(
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                    await DBManager.db.updateName(
                                        changeNameController.text,
                                        widget.friend.chatId);
                                    homeBloc =
                                        BlocProvider.of<HomeBloc>(context);
                                    homeBloc.add(FetchHomeChatsEvent());
                                  }
                                },
                                color: Constants.stuffColor,
                                child: Text(
                                  'DONE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: algo * 22.0,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.edit,
                  color: Constants.stuffColor,
                ),
              ),
            ),
            ListTileProfile(
              iconData: FontAwesomeIcons.solidUser,
              title: "Username",
              subTitle: widget.friend.username,
            ),
            Spacer(
              flex: 5,
            ),
            BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is BlockedUserState) {
                  setState(() {
                    isBlocked = true;
                  });
                } else {
                  setState(() {
                    isBlocked = false;
                  });
                }
              },
              child: isBlocked
                  ? DangerCard(Colors.green, 'UnBlock', () async {
                      chatBloc
                          .add(UnblockUserEvent(context, widget.friend.chatId));
                    })
                  : DangerCard(Colors.red, 'Block', () async {
                      _showPrompt(context);
                    }),
            ),
          ],
        ),
      ),
    );
  }
}
