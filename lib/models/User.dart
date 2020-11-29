import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String documentId;
  String phoneNumber;
  String username;
  String photoUrl;

  User({this.documentId, this.phoneNumber, this.username, this.photoUrl});

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return User(
        documentId: doc.documentID,
        phoneNumber: data['phoneNumber'],
        username: data['username'],
        photoUrl: data['photoUrl']);
  }
  factory User.fromMap(Map data) {
    return User(
        documentId: data['uid'],
        phoneNumber: data['phoneNumber'],
        username: data['username'],
        photoUrl: data['photoUrl']);
  }
  @override
  String toString() {
    return '{ documentId: $documentId, phoneNumb: $phoneNumber, username: $username, photoUrl: $photoUrl }';
  }
}
