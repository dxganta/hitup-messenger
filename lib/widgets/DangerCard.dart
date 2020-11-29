import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DangerCard extends StatelessWidget {
  final String title;
  final Function func;
  final Color color;

  DangerCard(this.color, this.title, this.func);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 15.0,
          ),
        ),
        leading: FaIcon(FontAwesomeIcons.skullCrossbones, color: color),
        onTap: func,
      ),
    );
  }
}
