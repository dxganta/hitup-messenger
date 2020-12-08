import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/functions/BaseFunctions.dart';
import 'package:coocoo/functions/ChatFunction.dart';
import 'package:coocoo/managers/db_manager.dart';
import 'package:coocoo/managers/mqtt_manager.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/models/NonContact.dart';
import 'package:coocoo/stateProviders/mqtt_state.dart';
import 'package:coocoo/stateProviders/number_state.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class UserDataFunction extends BaseUserDataFunction {
  Firestore _firestore = Firestore.instance;
  ChatFunction chatFunction = ChatFunction();

  @override
  void dispose() {}

  @override
  Future<List<NonContact>> loadNonContactsV2() async {
    List<NonContact> _nonContacts = [];
    Iterable<Contact> _contacts =
        await ContactsService.getContacts(withThumbnails: false);
    String countryCode =
        SharedObjects.prefs.getString(Constants.sessionCountryCode);

    await Future.forEach(_contacts, (_contact) async {
      String tempNum = cleanNumber(_contact, countryCode);

      if (tempNum != null) {
        bool contactExists =
            await DBManager.db.checkIfContactExistsInDb(tempNum);

        // if contact does not exist in local db then add it to the nonContacts list
        if (!contactExists) {
          print(tempNum);
          _nonContacts.add(NonContact(tempNum, name: _contact.displayName));
        }
      }
    });

    return _nonContacts;
  }

  @override
  Future<void> loadPhoneContactsV2(BuildContext context) async {
    Iterable<Contact> _contacts =
        await ContactsService.getContacts(withThumbnails: false);
    String countryCode =
        SharedObjects.prefs.getString(Constants.sessionCountryCode);

    try {
      await Future.forEach(_contacts, (_contact) async {
        String tempNum = cleanNumber(_contact, countryCode);
        String contactName = _contact.displayName;

        if (tempNum != null) {
          bool contactExists =
              await DBManager.db.checkIfContactExistsInDb(tempNum);

          if (!contactExists) {
            await addInstalledUserToDBANDSubscribe(
                context, tempNum, contactName);
          } else if (contactExists) {
            // however if contact exists in local db but does not exist in primary firestore
            // users database because he deleted his account then remove him from local db
            removeUninstalledUserFromDB(context, tempNum);
          }
        }
      });
    } catch (e, s) {
      print(s);
    }
  }

  void removeUninstalledUserFromDB(BuildContext context, String tempNum) async {
    final contactRef = _firestore.collection(Paths.usersPath).document(tempNum);

    contactRef.get().then((docSnapshot) async {
      if (!docSnapshot.exists) {
        // delete the contact from local Database
        await DBManager.db.deleteContact(tempNum);
      }
    });
  }

  Future<void> addInstalledUserToDBANDSubscribe(
      BuildContext context, String tempNum, String contactName) async {
    final contactRef = _firestore.collection(Paths.usersPath).document(tempNum);

    contactRef.get().then((docSnapshot) async {
      // if the user has installed the app then add him as a contact to my db
      // else do nothing
      if (docSnapshot.exists) {
        print("USER $tempNum EXISTS IN DB");
        String chatId = await chatFunction.createChatIdForContact(tempNum);

        // create a row for this user, i.e add the contact to my local db
        String photoUrl = docSnapshot.data["photoUrl"];
        String username = docSnapshot.data["username"];
        await DBManager.db.createRow(
            docSnapshot.documentID,
            chatId,
            contactName,
            username,
            photoUrl,
            1); // true because here this is a phone contact

        // Subscribe to the chatId
        MQTTManager manager = context.read<MQTTState>().manager;
        print("SUBSCRIBING TO TOPIC : $chatId");
        manager.subscribeTopic(chatId);
      }
    }).catchError((e) {
      print("e");
    });
  }

  dynamic cleanNumber(Contact dirtyNumber, String countryCode) {
    // when we clean a number, we first remove all the white spaces and hyphens and then
    // if the number does not has a country code,i.e, if its length is less than 11
    // then we add the user's country code.
    try {
      String num = dirtyNumber.phones.first.value;
      String num2 = num.replaceAll(RegExp(r"\D+"), '');
      if (num2.length < 11) {
        return "$countryCode$num2";
      } else {
        return num2;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PermissionStatus> askContactPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    return permissionStatus;
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.restricted) {
      Map<Permission, PermissionStatus> permissionStatus = await [
        Permission.contacts,
      ].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  @override
  Future<List<MyContact>> getContactsFromDB() async {
    List<MyContact> contacts = [];

    List<Map<dynamic, dynamic>> dbData = await DBManager.db.getAllContacts();

    dbData.forEach((map) {
      contacts.add(MyContact.fromMap(map));
    });

    return contacts;
  }

  @override
  void onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the RaisedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The RaisedButton's RenderObject
    // has its position and size after it's built.
    final RenderBox box = context.findRenderObject();
    await Share.share(
        "https://play.google.com/store/apps/details?id=com.digantakalita.coocoo",
        subject: "Lets have our private chats on"
            "this New Cool Messenger HitUp from now on. Its way safer than the others.",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  void sendNotification({String toUid, String title, String content}) async {
    final String app_id = "98194ba4-9b9a-416b-ab0c-74b851af4f1a";
    var body = jsonEncode({
      "include_external_user_ids": [toUid],
      "app_id": app_id,
      "contents": {"en": content},
      "headings": {"en": title},
      "collapse_id": "123",
      "android_channel_id": "0940813c-e319-4ff3-8d52-a202bf767b3a"
    });
    http.Response response = await http.post(
        'https://onesignal.com/api/v1/notifications',
        body: body,
        headers: {
          "content-type": "application/json",
          "Authorization":
              "Basic ZGY5MWZjZjctYmQ0My00ZDhjLTliYmItNzE0ZjlmOWVkYjYz"
        });
    if (response.statusCode == 200) {
      print("NOTIFICATION SENT SUCCESSFULLY");
    } else {
      print('Notification Error | Error Code: ${response.statusCode}');
    }
  }

  @override
  Future<void> verifyPhoneNumber(BuildContext context, String phoneNum,
      Function verificationFailed) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNum,
      timeout: Duration(seconds: 30),
      verificationCompleted: null,
      verificationFailed: verificationFailed,
      codeSent: (String verificationId, [int forceResendingToken]) async {
        context.read<NumberState>().setOTP(verificationId);
      },
      codeAutoRetrievalTimeout: null,
    );
  }
}
