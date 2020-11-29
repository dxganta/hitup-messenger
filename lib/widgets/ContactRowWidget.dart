import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/screens/chat_screen.dart';
import 'package:coocoo/widgets/ContactCard.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ContactRowWidget extends StatelessWidget {
  ContactRowWidget({
    Key key,
    @required this.contact,
  }) : super(key: key);
  final MyContact contact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(contact),
              ));
        },
        child: ContactCard(
          name: contact.name,
          profilePic: contact.photoUrl,
          status: '@${contact.username ?? contact.phoneNumber}',
        ));
  }
}
