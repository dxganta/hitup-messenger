import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/config/Paths.dart';
import 'package:coocoo/constants.dart';
import 'package:coocoo/functions/ChatFunction.dart';
import 'package:coocoo/stateProviders/profilePicUrlState.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:coocoo/widgets/ListTileProfile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final picker = ImagePicker();
  File profileImageFile;
  ImageProvider profileImage;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  Firestore fireStoreDb = Firestore.instance;
  bool uploadingDp = false;
  ChatFunction chatFunction;

  @override
  Widget build(BuildContext context) {
    profileImage = CachedNetworkImageProvider(
        context.watch<ProfilePicUrlState>().profilePicUrl);
    double screenWidth = MediaQuery.of(context).size.width;
    double algo = screenWidth / perfectWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: algo * 10.0, horizontal: algo * 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Opacity(
                  opacity: uploadingDp ? 0.5 : 1.0,
                  child: Hero(
                    tag: 'myProfile',
                    child: CircleAvatar(
                      radius: algo * 120.0,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImage,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: uploadingDp
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : Container(),
                  ),
                ),
                Positioned(
                  bottom: algo * 5.0,
                  right: algo * 10.0,
                  child: GestureDetector(
                    onTap: () {
                      pickImage(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      radius: algo * 30.0,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.blueGrey,
                        size: algo * 33.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Spacer(
              flex: 2,
            ),
            ListTileProfile(
              iconData: FontAwesomeIcons.solidUser,
              title: 'Username',
              subTitle:
                  SharedObjects.prefs.getString(Constants.sessionUsername) ??
                      "",
            ),
            ListTileProfile(
              iconData: FontAwesomeIcons.book,
              title: 'Full Name',
              subTitle: SharedObjects.prefs.getString(Constants.fullName),
            ),
            ListTileProfile(
              iconData: Icons.phone,
              title: 'Phone Number',
              subTitle: SharedObjects.prefs.getString(Constants.sessionUid),
            ),
            Spacer(
              flex: 9,
            ),
          ],
        ),
      ),
    );
  }

  Future pickImage(BuildContext context) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImageFile = File(pickedFile.path);
      setState(() {
        uploadingDp = true;
      });
      String profileImageUrl =
          await uploadFile(profileImageFile, Paths.profilePicturePath);
      await saveProfilePicture(profileImageUrl, context);
      setState(() {
        uploadingDp = false;
        profileImage = FileImage(profileImageFile);
      });
    }
  }

  Future<void> saveProfilePicture(
      String profileImageUrl, BuildContext context) async {
    String uid = SharedObjects.prefs.getString(Constants.sessionUid);

    DocumentReference ref = fireStoreDb.collection(Paths.usersPath).document(
        uid); //reference of the user's document node in database/users. This node is created using uid
    var data = {
      'photoUrl': profileImageUrl,
    };
    await ref.setData(data, merge: true); // set the photourl, age and username
    await SharedObjects.prefs
        .setString(Constants.sessionProfilePictureUrl, profileImageUrl);
    context.read<ProfilePicUrlState>().setProfilePicUrl(profileImageUrl);

    // notify my contacts devices that I have changed my DP
    chatFunction = ChatFunction();
    ref.get().then((snapshot) {
      var chatIds = snapshot.data["chats"];
      String msgToSend =
          '{"msg" : "${Constants.profilePicChangeMsg}", "profilePicUrl" : "$profileImageUrl",'
          '"uid" : "$uid", "type" : "service"}';
      chatIds.values.forEach((chatId) {
        chatFunction.sendServiceMsgToServer(context, msgToSend, chatId);
      });
    });
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

  Future<String> uploadFile(File file, String path) async {
    String username = SharedObjects.prefs.getString(Constants.sessionUsername);
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
}
