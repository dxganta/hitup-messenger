import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/screens/profile_screen.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/managers/db_manager.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:coocoo/widgets/DangerCard.dart';
import 'package:coocoo/widgets/SettingsTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../splashscreen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final Firestore _firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;

  Future<bool> _showDialogBox() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('You want to delete your HitUp account?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  String userPhone =
                      SharedObjects.prefs.getString(Constants.sessionUid);

                  try {
                    _firestore
                        .collection(Paths.usersPath)
                        .document(userPhone)
                        .delete();
                  } catch (e) {
                    print(e);
                  }
                  DBManager.db.deleteTable();
                  await SharedObjects.prefs.clearAll();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SplashScreen()));
                  setState(() {
                    loading = false;
                  });
                },
                child: Text('Yes Delete'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: !loading
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingsTile(
                    icon: Icons.account_circle,
                    title: 'My Account',
                    onPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()));
                    },
                  ),
                  DangerCard(Colors.red, 'Delete Account', () {
                    _showDialogBox();
                  }),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
