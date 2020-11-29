import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onPress;

  SettingsTile({@required this.icon, @required this.title, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: Icon(icon, color: Colors.blueGrey),
        onTap: onPress,
      ),
    );
  }
}
