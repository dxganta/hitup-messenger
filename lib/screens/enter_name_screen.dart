import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/screens/update_profile.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:coocoo/widgets/NameTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class EnterName extends StatefulWidget {
  @override
  _EnterNameState createState() => _EnterNameState();
}

class _EnterNameState extends State<EnterName> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Firestore firestore = Firestore.instance;
  bool isLoading = false;

  Future<void> saveFullName(String firstname, String lastname) async {
    String uid = SharedObjects.prefs.getString(Constants.sessionUid);
    String fullName = '$firstname $lastname';

    DocumentReference ref = firestore.collection(Paths.usersPath).document(
        uid); //reference of the user's document node in database/users. This node is created using uid
    var data = {'name': fullName};
    await ref.setData(data, merge: true); // set the photourl, age and username
    await SharedObjects.prefs.setString(Constants.fullName, fullName);
  }

  Widget buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildEnterNameScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 40.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Center(
              child: Text("What's your name?",
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            SizedBox(height: 8.0),
            Column(
              children: [
                NameTextField(
                  hintText: 'FIRST NAME',
                  controller: firstNameController,
                ),
                NameTextField(
                  hintText: 'LAST NAME',
                  controller: lastNameController,
                ),
                SizedBox(height: 10.0),
                Text("This name will appear when someone searches for you "
                    "on HitUp")
              ],
            ),
            SizedBox(height: 40.0),
            RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  await saveFullName(
                      firstNameController.text, lastNameController.text);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UpdateProfile()));
                  isLoading = false;
                }
              },
              elevation: 10.0,
              color: Colors.blueAccent[400],
              child: Text(
                "NEXT",
                style: TextStyle(
                    color: Colors.white, fontSize: 25.0, letterSpacing: 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? buildLoadingScreen() : buildEnterNameScreen(),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}
