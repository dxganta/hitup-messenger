import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:flutter/material.dart';

String NoDpUrl =
    "https://firebasestorage.googleapis.com/v0/b/coocoo-private-fc1e0.appspot.com/o/user.png?alt=media&token=0572ebb8-630d-4468-b5e1-91fd4cc9e049";

class ProfilePicUrlState with ChangeNotifier {
  String _profilePicUrl =
      SharedObjects.prefs.getString(Constants.sessionProfilePictureUrl) ??
          NoDpUrl;

  String get profilePicUrl => _profilePicUrl;

  void setProfilePicUrl(String newUrl) {
    _profilePicUrl = newUrl;
    notifyListeners();
  }
}
