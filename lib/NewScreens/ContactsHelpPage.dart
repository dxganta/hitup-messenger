import 'package:coocoo/constants.dart';
import 'package:flutter/material.dart';

class ContactsHelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts Help'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "    If some of your friends don't appear in\n    the contacts"
              " list, we recommend\n    the following steps:",
              style: TextStyle(
                fontSize: (screenWidth / perfectWidth) * 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              "1. Click on the Refresh Button on the\n "
              "   Top right hand side of the page and "
              "\n    check for the contact again.",
              style: TextStyle(
                fontSize: (screenWidth / perfectWidth) * 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              "2. Make sure that your friend is using\n     HitUp Messenger",
              style: TextStyle(
                fontSize: (screenWidth / perfectWidth) * 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              "3. Make sure that your friend's phone number\n     is in your "
              "address book",
              style: TextStyle(
                fontSize: (screenWidth / perfectWidth) * 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
