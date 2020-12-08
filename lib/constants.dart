import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

const kMobileTextFieldDecoration = InputDecoration(
  hintText: 'Enter Mobile Number',
  contentPadding: EdgeInsets.symmetric(vertical: 1.5),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFF6A1B9A),
      width: 2.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFF6A1B9A),
      width: 2.0,
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFF6A1B9A),
      width: 2.0,
    ),
  ),
);

const kChatsGroupsTextStyle = TextStyle(
  fontSize: 17.0,
  fontWeight: FontWeight.w600,
);

const kCircleNeumorphicStyle = NeumorphicStyle(
  shadowDarkColor: Colors.black,
  shadowLightColor: Colors.white,
  boxShape: NeumorphicBoxShape.circle(),
  depth: 7,
  intensity: 0.7,
  surfaceIntensity: 0.6,
  shape: NeumorphicShape.convex,
);

const kChatCircleNeumorphicStyle = NeumorphicStyle(
  shadowDarkColor: Colors.black,
  shadowLightColor: Colors.white,
  boxShape: NeumorphicBoxShape.circle(),
  depth: 5,
  intensity: 0.65,
  surfaceIntensity: 0.6,
);

const kRequestTitleStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 23.0,
);

const double perfectWidth = 411.4; // 683.4;

const kHitUpIdTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
  hintText: 'Search Username',
  fillColor: Colors.white,
  filled: true,
  border: OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(40.0),
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(40.0),
    ),
  ),
);
