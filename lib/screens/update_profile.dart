import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/functions/MQTTFunction.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/screens/home_screen.dart';
import 'package:coocoo/stateProviders/profilePicUrlState.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum PageState { initial, updating }

class UpdateProfile extends StatefulWidget {
  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  PageState profilePageState = PageState.initial;
  UserDataFunction userDataFunction;
  MQTTFunction mqttFunction;
  final _formKey = GlobalKey<FormState>();

  File profileImageFile;
  ImageProvider profileImage = AssetImage('images/user.png');
  final TextEditingController usernameController = TextEditingController();
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  Firestore fireStoreDb = Firestore.instance;
  final picker = ImagePicker();
  String NoDpUrl =
      "https://firebasestorage.googleapis.com/v0/b/coocoo-private-fc1e0.appspot.com/o/user.png?alt=media&token=0572ebb8-630d-4468-b5e1-91fd4cc9e049";

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: buildUpdateProfilePage(context),
      ),
    );
  }

  Widget buildUpdateProfilePage(BuildContext context) {
    if (profilePageState == PageState.initial) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 15.0),
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        'Profile Info',
                        style: TextStyle(
                          color: Constants.textStuffColor,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        "Please provide an username and a profile photo",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: pickImage,
                              child: CircleAvatar(
                                backgroundImage: profileImage,
                                radius: 35,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'\s+')) // no spaces allowed
                                ],
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter a valid username';
                                  }
                                  return null;
                                },
                                controller: usernameController,
                                maxLengthEnforced: true,
                                maxLength: 26,
                                cursorColor: Constants.stuffColor,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'username',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  RaisedButton(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                    color: Constants.stuffColor,
                    child: Text(
                      'NEXT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        letterSpacing: 1.0,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          profilePageState = PageState.updating;
                        });
                        // set profile image
                        if (profileImageFile != null) {
                          String profilePictureUrl = await uploadFile(
                              profileImageFile,
                              Paths.profilePicturePath,
                              usernameController.text);
                          await saveProfileDetails(profilePictureUrl,
                              usernameController.text, context);
                        } else {
                          await saveProfileDetails(
                              NoDpUrl, usernameController.text, context);
                        }

                        // get contacts permission and load the phone contacts
                        userDataFunction = UserDataFunction();
                        PermissionStatus currPermission =
                            await userDataFunction.askContactPermissions();
                        if (currPermission == PermissionStatus.granted) {
                          await userDataFunction.loadPhoneContactsV2(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        } else {
                          setState(() {
                            profilePageState = PageState.initial;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (profilePageState == PageState.updating) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> saveProfileDetails(
      String profileImageUrl, String username, BuildContext context) async {
    String uid = SharedObjects.prefs.getString(Constants.sessionUid);
    print('Session UID of PROFILE : $uid');

    DocumentReference ref = fireStoreDb.collection(Paths.usersPath).document(
        uid); //reference of the user's document node in database/users. This node is created using uid
    var data = {
      'photoUrl': profileImageUrl,
      'username': username,
    };
    await ref.setData(data, merge: true); // set the photourl, age and username
    await SharedObjects.prefs.setString(Constants.sessionUsername, username);
    await SharedObjects.prefs
        .setString(Constants.sessionProfilePictureUrl, profileImageUrl);
    context.read<ProfilePicUrlState>().setProfilePicUrl(profileImageUrl);
  }

  // 2. compress file and get file.
  Future<File> testCompressAndGetFile(File file, String username) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tempPath + "/$username.jpg",
      minHeight: 500,
      minWidth: 500,
      quality: 80,
    );
    return result;
  }

  Future<String> uploadFile(File file, String path, String username) async {
    file = await testCompressAndGetFile(file, username);

    String fileName = basename(file.path);
    final milliSecs = DateTime.now().millisecondsSinceEpoch;
    StorageReference reference = firebaseStorage.ref().child(
        '$path/$milliSecs\_$fileName'); // get a reference to the path of the image directory
    String uploadPath = await reference.getPath();
    print('uploading to $uploadPath');
    StorageUploadTask uploadTask =
        reference.putFile(file); // put the file in the path
    StorageTaskSnapshot result =
        await uploadTask.onComplete; // wait for the upload to complete
    String url = await result.ref
        .getDownloadURL(); //retrieve the download link and return it
    return url;
  }

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    print('Picked file path is : ' + pickedFile.path);
    profileImageFile = File(pickedFile.path);
    setState(() {
      profileImage = FileImage(profileImageFile);
    });
  }
}
