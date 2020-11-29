import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/functions/BaseFunctions.dart';
import 'package:coocoo/functions/ChatFunction.dart';
import 'package:coocoo/managers/db_manager.dart';
import 'package:coocoo/managers/mqtt_manager.dart';
import 'package:coocoo/stateProviders/mqtt_state.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AddFriendsFunction extends BaseAddFriendsFunction {
  Firestore _firestore = Firestore.instance;
  ChatFunction chatFunction = ChatFunction();
  String uid = SharedObjects.prefs.getString(Constants.sessionUid);

  @override
  void dispose() {}

  @override
  Future<void> addToFriendRequestsCollection(String phoneNumber) async {
    // add to friend requests collection of the other user
    CollectionReference usersRef = _firestore.collection(Paths.usersPath);

    // first get my data
    DocumentSnapshot snapshot = await usersRef.document(uid).get();

    usersRef
        .document(phoneNumber)
        .collection(Paths.friendRequestsPath)
        .document(uid)
        .setData({
      'username': snapshot.data['username'],
      'photoUrl': snapshot.data['photoUrl'],
      'name': snapshot.data['name'],
      'phoneNumber': snapshot.data['phoneNumber'],
    });
  }

  @override
  Future<String> addToLocalDBAndSubscribe(
      BuildContext context, String phoneNumber) async {
    DocumentSnapshot docSnapshot = await _firestore
        .collection(Paths.usersPath)
        .document(phoneNumber)
        .get();

    String chatId = await chatFunction.createChatIdForContact(phoneNumber);

    // create a row for this user, i.e add the contact to my local db
    String photoUrl = docSnapshot.data["photoUrl"];
    String username = docSnapshot.data["username"];
    String name = docSnapshot.data["name"];
    await DBManager.db.createRow(phoneNumber, chatId, name, username, photoUrl,
        0); // 0 because here this is not a phone contact

    // Subscribe to the chatId
    MQTTManager manager = context.read<MQTTState>().manager;
    print("SUBSCRIBING TO TOPIC : $chatId");
    manager.subscribeTopic(chatId);

    return chatId;
  }

  @override
  Future<void> addToSentRequestsCollection(String phoneNumber) async {
    // add to my sent requests collection
    CollectionReference usersRef = _firestore.collection(Paths.usersPath);

    // first get the data for the phoneNumber
    DocumentSnapshot snapshot = await usersRef.document(phoneNumber).get();

    usersRef
        .document(uid)
        .collection(Paths.sentRequestsPath)
        .document(phoneNumber)
        .setData({
      'username': snapshot.data['username'],
      'photoUrl': snapshot.data['photoUrl'],
      'name': snapshot.data['name'],
      'phoneNumber': snapshot.data['phoneNumber'],
    });
  }

  @override
  Future<HitUpIdLocation> checkHitUpId(String hitUpId) async {
    bool ans;
    // check if hitUpId exists in local db
    ans = await DBManager.db.checkIfUsernameExistsInDb(hitUpId);

    if (ans) {
      return HitUpIdLocation.InLocalDb;
    } else {
      // check if hitUpId exists in Firebase Friend Requests collection
      String uid = SharedObjects.prefs.getString(Constants.sessionUid);
      QuerySnapshot snapshot = await _firestore
          .collection(Paths.usersPath)
          .document(uid)
          .collection(Paths.friendRequestsPath)
          .where('username', isEqualTo: hitUpId)
          .limit(1)
          .getDocuments();

      if (snapshot.documents.length > 0) {
        return HitUpIdLocation.InFriendRequests;
      } else {
        // check if hitUpId exists in Firebase Sent Requests Collection
        snapshot = await _firestore
            .collection(Paths.usersPath)
            .document(uid)
            .collection(Paths.sentRequestsPath)
            .where('username', isEqualTo: hitUpId)
            .limit(1)
            .getDocuments();

        if (snapshot.documents.length > 0) {
          return HitUpIdLocation.InSentRequests;
        } else {
          return HitUpIdLocation.Nowhere;
        }
      }
    }
  }

  @override
  Future<void> removeFromFriendRequestsCollection(String phoneNumber) async {
    // remove from my friend requests collection
    CollectionReference usersRef = _firestore.collection(Paths.usersPath);

    await usersRef
        .document(uid)
        .collection(Paths.friendRequestsPath)
        .document(phoneNumber)
        .delete();
  }

  @override
  void removeFromSentRequestsCollection(String phoneNumber) {
    // remove from the other user's sent requests collection
    CollectionReference usersRef = _firestore.collection(Paths.usersPath);

    usersRef
        .document(phoneNumber)
        .collection(Paths.sentRequestsPath)
        .document(uid)
        .delete();
  }
}
