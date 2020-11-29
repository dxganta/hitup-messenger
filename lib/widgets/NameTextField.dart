import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NameTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  NameTextField({this.hintText, this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s+')) // no spaces allowed
        ],
        validator: (value) {
          if (value.trim().isEmpty) {
            return 'Please enter a valid $hintText';
          }
          return null;
        },
        controller: controller,
        style: TextStyle(
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.only(bottom: -15.0),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
