import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientSnackBar {
  static void showMessage(
      BuildContext context, String message, int secondsDuration) {
    Flushbar(
      message: message,
      duration: Duration(seconds: secondsDuration),
      backgroundGradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green, Colors.blueAccent]),
      backgroundColor: Colors.red,
      boxShadows: [
        BoxShadow(
          color: Colors.blue[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    )..show(context);
  }

  static void showError(BuildContext context, String error) {
    Flushbar(
      message: error,
      duration: Duration(milliseconds: 1500),
      backgroundGradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomRight,
          colors: [
            Colors.red[700],
            Colors.blueGrey,
          ]),
      backgroundColor: Colors.red,
      boxShadows: [
        BoxShadow(
          color: Colors.blue[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    )..show(context);
  }
}
