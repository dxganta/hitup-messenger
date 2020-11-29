import 'package:flutter/material.dart';

class ListTileProfile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subTitle;
  final Widget trailingWidget;

  ListTileProfile(
      {this.iconData, this.title, this.subTitle, this.trailingWidget});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      child: ListTile(
        leading: Icon(
          iconData,
          color: Colors.blueGrey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          subTitle,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
          ),
        ),
        trailing: trailingWidget,
      ),
    );
  }
}
