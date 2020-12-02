import 'dart:io';

import 'package:coocoo/models/ChatMessage.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/models/NonContact.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

enum HitUpIdLocation {
  InLocalDb,
  InFriendRequests,
  InSentRequests,
  Nowhere,
}

abstract class BaseFunction {
  void dispose();
}

abstract class BaseUserDataFunction extends BaseFunction {
  Future<List<MyContact>> getContactsFromDB();
  Future<void> loadPhoneContactsV2(BuildContext context);
  Future<List<NonContact>> loadNonContactsV2();
  Future<PermissionStatus> askContactPermissions();
  void onShare(BuildContext context);
  void sendNotification({String toUid, String title, String content});
  Future<void> verifyPhoneNumber(
      BuildContext context, String phoneNum, Function verificationFailed);
}

abstract class BaseChatFunction extends BaseFunction {
  Future<void> createChatIdForContact(String contactPhoneNumber);
  void sendMessageToServer(BuildContext context, String msg, String chatId);
  void sendImageToServer(BuildContext context, File imageFile, String chatId);
  void sendServiceMsgToServer(BuildContext context, String msg, String chatId);
  Future<List<ChatMessage>> getAllMsgsFromMessagesTable(String chatId);
  void blockUser(BuildContext context, String chatId);
  void unBlockUser(BuildContext context, String chatId);
}

abstract class BaseMQTTFunction extends BaseFunction {
  Future<void> connect(BuildContext context);
  void disconnect();
}

abstract class BaseUIFunction extends BaseFunction {
  double cleanValue(double screenWidth, double value);
}

abstract class BaseAddFriendsFunction extends BaseFunction {
  Future<String> addToLocalDBAndSubscribe(
      BuildContext context, String phoneNumber);
  Future<void> addToFriendRequestsCollection(String phoneNumber);
  Future<void> addToSentRequestsCollection(String phoneNumber);
  Future<HitUpIdLocation> checkHitUpId(String hitUpId);
  Future<void> removeFromFriendRequestsCollection(String phoneNumber);
  void removeFromSentRequestsCollection(String phoneNumber);
}
