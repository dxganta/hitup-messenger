import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "For help with any issues, bugs or feature requests please write a review "
              "on Google Play Store or directly contact us "
              "at: ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            Column(
              children: [
                ContactMeCard(
                  iconData: FontAwesomeIcons.envelope,
                  title: 'digantakalita.ai@gmail.com',
                ),
                ContactMeCard(
                  iconData: FontAwesomeIcons.instagram,
                  title: '@digantakalita_real',
                ),
                ContactMeCard(
                  iconData: FontAwesomeIcons.twitter,
                  title: '@realdiganta',
                ),
                ContactMeCard(
                  iconData: FontAwesomeIcons.whatsapp,
                  title: '+91 1111111111',
                ),
                SizedBox(height: 10.0),
                Text(
                  "If your messages are not being sent, just check your "
                  "internet connection or restart the app,"
                  " and it will start working fine af",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                )
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              "We typically reply within 4 hours",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactMeCard extends StatelessWidget {
  final IconData iconData;
  final String title;

  ContactMeCard({this.iconData, this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: ListTile(
        leading: FaIcon(
          iconData,
          color: Colors.pinkAccent,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 19.0,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
