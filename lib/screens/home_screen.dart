import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/screens/contacts_screen.dart';
import 'package:coocoo/screens/profile_screen.dart';
import 'package:coocoo/screens/settings_screen.dart';
import 'package:coocoo/blocs/home/home_bloc.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/models/Conversation.dart';
import 'package:coocoo/stateProviders/profilePicUrlState.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:coocoo/widgets/ChatCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  HomeBloc homeBloc;

  List<Conversation> conversations;

  void setUserNameAndNameIfNull() {
    Firestore _firestore = Firestore.instance;
    String uid = SharedObjects.prefs.getString(Constants.sessionUid);
    String username = SharedObjects.prefs.getString(Constants.sessionUsername);
    String fullName = SharedObjects.prefs.getString(Constants.fullName);

    if (username == null || fullName == null) {
      _firestore.collection(Paths.usersPath).document(uid).get().then((doc) {
        SharedObjects.prefs
            .setString(Constants.sessionUsername, doc.data["username"]);
        SharedObjects.prefs.setString(Constants.fullName, doc.data["name"]);
        SharedObjects.prefs.setString(
            Constants.sessionProfilePictureUrl, doc.data["photoUrl"]);
      });
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the App'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () =>
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void initOneSignal() async {
    await OneSignal.shared.init("98194ba4-9b9a-416b-ab0c-74b851af4f1a",
        iOSSettings: {
          OSiOSSettings.autoPrompt: false,
          OSiOSSettings.inAppLaunchUrl: false
        });
    await OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    final String myUid = SharedObjects.prefs.getString(Constants.sessionUid);
    await OneSignal.shared.setExternalUserId(myUid);

    OneSignal.shared.addTrigger('update', '1');
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initOneSignal();
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();

    // connecting to the mqtt server in the home page
    homeBloc.add(ConnectToServerEvent(context));
    setUserNameAndNameIfNull();
    print("Home Screen Opened");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      homeBloc.add(DisconnectEvent());
    }
    if (state == AppLifecycleState.resumed) {
      homeBloc.add(ConnectToServerEvent(context));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ContactListPage()));
          },
          backgroundColor: Colors.blueGrey[600],
          elevation: 15.0,
          child: Icon(
            Icons.message,
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      'Chats',
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontSize: (screenWidth / perfectWidth) * 30.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(
                      flex: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 15.0),
                        child: Hero(
                          tag: 'myProfile',
                          child: Neumorphic(
                            style: kCircleNeumorphicStyle,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: (screenWidth / perfectWidth) * 33.0,
                              backgroundImage: CachedNetworkImageProvider(
                                  context
                                      .watch<ProfilePicUrlState>()
                                      .profilePicUrl),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsScreen()));
                      },
                      child: Icon(
                        Icons.more_vert,
                        size: (screenWidth / perfectWidth) * 30.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Expanded(
                    flex: 3,
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        conversations = state.conversations;
                        if (conversations.length > 0 &&
                            conversations.isNotEmpty) {
                          return ListView.builder(
                              itemCount: conversations.length,
                              itemBuilder: (context, index) {
                                return ChatCard(conversations[index], index);
                              });
                        } else {
                          return Center(child: Text("You have No Messages"));
                        }
                      },
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
