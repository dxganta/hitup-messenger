import 'package:flutter/material.dart';

class NumberState with ChangeNotifier {
  String _otp;
  String _phoneNumber;
  String _username;

  String get otp => _otp;
  String get phoneNumber => _phoneNumber;
  String get username => _username;

  void setOTP(String newValue) {
    _otp = newValue;
    notifyListeners();
  }

  void setPhoneNumber(String newphoneNumber) {
    _phoneNumber = newphoneNumber;
    notifyListeners();
  }
}
