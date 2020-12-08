import 'package:coocoo/screens/login_screen.dart';
import 'package:coocoo/functions/MQTTFunction.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/screens/home_screen.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool newUser;
  UserDataFunction userDataFunction;
  MQTTFunction mqttFunction;
  String loggedInUser;

  void checkIfAlreadyLogin(BuildContext context) async {
    newUser = (SharedObjects.prefs.getBool('login') ?? true);
    print(newUser);
    if (newUser == false) {
      userDataFunction = UserDataFunction();
      PermissionStatus currPermission =
          await userDataFunction.askContactPermissions();
      if (currPermission == PermissionStatus.granted) {
        // load Contacts here itself
        await userDataFunction.loadPhoneContactsV2(context);
        // wait a little time for loading
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkIfAlreadyLogin(context));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 22.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      offset: Offset(2.5, 3.5), //(x,y)
                      blurRadius: 2.5,
                    ),
                  ],
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40.0),
                    bottomLeft: Radius.circular(40.0),
                  ),
                ),
                child: Center(
                    child: Icon(
                  Icons.favorite,
                  size: 80.0,
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
