import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/functions/AddFriendsFunction.dart';
import 'package:coocoo/functions/BaseFunctions.dart';
import 'package:coocoo/functions/ChatFunction.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:coocoo/widgets/GradientSnackBar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'add_friends_event.dart';
part 'add_friends_state.dart';

class AddFriendsBloc extends Bloc<AddFriendsEvent, AddFriendsState> {
  AddFriendsBloc() : super(AddFriendsInitial());

  Firestore _firestore = Firestore.instance;
  AddFriendsFunction addFriendsFunction = AddFriendsFunction();
  ChatFunction chatFunction = ChatFunction();
  UserDataFunction userDataFunction = UserDataFunction();
  String myName = SharedObjects.prefs.getString(Constants.fullName);

  @override
  Stream<AddFriendsState> mapEventToState(
    AddFriendsEvent event,
  ) async* {
    if (event is SearchHitUpIdEvent) {
      yield* mapSearchHitUpIdEventToState(event);
    }
    if (event is AddButtonClickEvent) {
      yield* mapAddButtonClickEventToState(event);
    }
    if (event is AcceptFriendRequestEvent) {
      yield* mapAcceptFriendRequestEventToState(event);
    }
    if (event is DeclineFriendRequestEvent) {
      yield* mapDeclineFriendRequestEventToState(event);
    }
  }

  Stream<AddFriendsState> mapDeclineFriendRequestEventToState(
      DeclineFriendRequestEvent event) async* {
    yield DecliningFriendRequestState();
    await addFriendsFunction
        .removeFromFriendRequestsCollection(event.phoneNumber);
    addFriendsFunction.removeFromSentRequestsCollection(event.phoneNumber);
    yield FriendRequestDeclinedState();
  }

  Stream<AddFriendsState> mapAcceptFriendRequestEventToState(
      AcceptFriendRequestEvent event) async* {
    yield AcceptingFriendRequestState();
    String chatId = await addFriendsFunction.addToLocalDBAndSubscribe(
        event.context, event.phoneNumber);
    chatFunction.sendMessageToServer(
        event.context, 'Hi, I have accepted your friend request', chatId);

    await addFriendsFunction
        .removeFromFriendRequestsCollection(event.phoneNumber);
    yield FriendRequestAcceptedState();
    userDataFunction.sendNotification(toUid:event.phoneNumber, title: "New Notification", content: "$myName has accepted your friend request");
    GradientSnackBar.showMessage(event.context, "Friend Request Accepted", 1);
    addFriendsFunction.removeFromSentRequestsCollection(event.phoneNumber);
  }

  Stream<AddFriendsState> mapAddButtonClickEventToState(
      AddButtonClickEvent event) async* {
    yield SendingFriendRequestState();
    await addFriendsFunction.addToLocalDBAndSubscribe(
        event.context, event.friend.phoneNumber);
    await addFriendsFunction
        .addToSentRequestsCollection(event.friend.phoneNumber);
    yield FriendRequestSentState(event.friend);
    userDataFunction.sendNotification(toUid:event.friend.phoneNumber, title: "New Notification", content: "$myName has sent you a friend request");
    addFriendsFunction.addToFriendRequestsCollection(event.friend.phoneNumber);
  }

  Stream<AddFriendsState> mapSearchHitUpIdEventToState(
      SearchHitUpIdEvent event) async* {
    yield SearchingHitUpIdState();

    final HitUpIdLocation hitUpIdLocation =
        await addFriendsFunction.checkHitUpId(event.hitUpId);

    // if hitUpId does not exists in local db, friend requests & sent requests
    if (hitUpIdLocation == HitUpIdLocation.Nowhere) {
      QuerySnapshot snapshot = await _firestore
          .collection(Paths.usersPath)
          .where("username", isEqualTo: event.hitUpId)
          .limit(1)
          .getDocuments();

      if (snapshot.documents.length > 0) {
        DocumentSnapshot doc = snapshot.documents[0];
        yield HitUpIdExistsState(MyContact.fromFireStore(doc));
      } else {
        yield HitUpIdNotExistsState(event.hitUpId);
      }
    } else {
      yield HitUpIdAlreadyThere(event.hitUpId, hitUpIdLocation);
    }
  }
}
