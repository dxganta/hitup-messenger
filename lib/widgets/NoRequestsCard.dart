import 'package:coocoo/config/Constants.dart';
import 'package:flutter/material.dart';

class NoRequestsCard extends StatelessWidget {
  final double algo;
  final String text;

  NoRequestsCard({
    @required this.algo,
    @required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 8.0),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: algo * 20.0,
                color: Constants.textStuffColor,
              )),
        ),
      ),
    );
  }
}
