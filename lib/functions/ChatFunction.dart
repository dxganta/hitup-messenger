import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/functions/BaseFunctions.dart';
import 'package:coocoo/managers/db_manager.dart';
import 'package:coocoo/managers/mqtt_manager.dart';
import 'package:coocoo/models/ChatMessage.dart';
import 'package:coocoo/stateProviders/mqtt_state.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ChatFunction extends BaseChatFunction {
  Firestore _firestore = Firestore.instance;
  MQTTManager _manager;
  String myUid = SharedObjects.prefs.getString(Constants.sessionUid);

  @override
  Future<String> createChatIdForContact(String contactPhoneNumber) async {
    String chatId;
    String uId = SharedObjects.prefs.getString(Constants.sessionUid);
    CollectionReference usersCollection =
        _firestore.collection(Paths.usersPath);
    DocumentReference userRef = usersCollection.document(uId);
    DocumentReference contactRef = usersCollection.document(contactPhoneNumber);
    DocumentSnapshot userSnapshot = await userRef.get();

    // if chatId doesn't exists for that contact then create new ChatId and update it
    // for both the user and the contact
    // else use the chatId which already exists
    if (userSnapshot.data['chats'] == null ||
        userSnapshot.data['chats'][contactPhoneNumber] == null) {
      chatId = createChatId();
      await userRef.setData({
        'chats': {contactPhoneNumber: chatId}
      }, merge: true);
      await contactRef.setData({
        'chats': {uId: chatId}
      }, merge: true);
    } else {
      chatId = userSnapshot.data['chats'][contactPhoneNumber];
    }

    return chatId;
  }

  String createChatId() {
    final Random _random = Random.secure();
    final int idLength = 16; // length of the chatId

    var values = List<int>.generate(idLength, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }

  @override
  void dispose() {}

  @override
  void sendMessageToServer(BuildContext context, String msg, String chatId) {
    if (_manager == null) {
      _manager = context.read<MQTTState>().manager;
    }
    print("calling send message to server");
    Map msgMap = {"msg": "$msg", "type": "text", "uid": "$myUid"};
    String msgToSend = json.encode(msgMap);
    _manager.publish(msgToSend, chatId);
  }

  @override
  Future<List<ChatMessage>> getAllMsgsFromMessagesTable(String chatId) async {
    return await DBManager.db.readAllMessagesfromMessagesTable(chatId);
  }

  // 2. compress file and get file.
  Future<File> testCompressAndGetFile(File file) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tempPath + "/temp.jpg",
      minHeight: 400,
      minWidth: 400,
      quality: 80,
    );
    return result;
  }

  @override
  void sendImageToServer(
      BuildContext context, File imageFile, String chatId) async {
    if (_manager == null) {
      _manager = context.read<MQTTState>().manager;
    }

    // compress the image & make it smaller in size
    File newFile = await testCompressAndGetFile(imageFile);

    // change the image to bytes format
    String base64Image = base64Encode(newFile.readAsBytesSync());
    String msgToSend =
        '{"msg" : "$base64Image", "type" : "image", "uid" : "$myUid"}';

    while (!_manager.getConnectionStatus()) {
      print("NOT CONNECTED BEFORE PUBLISHING");
      await Future.delayed(Duration(seconds: 1));
    }

    print("CONNECTED BEFORE PUBLISHING");
    _manager.publish(msgToSend, chatId);
  }

  @override
  void sendServiceMsgToServer(BuildContext context, String msg, String chatId) {
    if (_manager == null) {
      _manager = context.read<MQTTState>().manager;
    }
    _manager.publish(msg, chatId);
  }

  @override
  void blockUser(BuildContext context, String chatId) {
    if (_manager == null) {
      _manager = context.read<MQTTState>().manager;
    }
    DBManager.db.updateBlockStatus(0, chatId);
    _manager.unSubscribeTopic(chatId);
  }

  @override
  void unBlockUser(BuildContext context, String chatId) {
    if (_manager == null) {
      _manager = context.read<MQTTState>().manager;
    }
    DBManager.db.updateBlockStatus(1, chatId);
    _manager.subscribeTopic(chatId);
  }
}
