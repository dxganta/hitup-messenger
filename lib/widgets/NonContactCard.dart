import 'package:flutter/material.dart';
import 'package:share/share.dart';

class NonContactCard extends StatelessWidget {
  final String name;

  NonContactCard(
    this.name,
  );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 18.0,
        backgroundImage: AssetImage('images/user.png'),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
        ),
      ),
      trailing: FlatButton(
        child: Text(
          'Invite',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Colors.green,
        onPressed: () => _onShare(context),
      ),
    );
  }

  _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the RaisedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The RaisedButton's RenderObject
    // has its position and size after it's built.
    final RenderBox box = context.findRenderObject();
    await Share.share(
        "https://play.google.com/store/apps/details?id=com.digantakalita.coocoo",
        subject: "Lets have our private chats on"
            "this New Cool Messenger HitUp from now on. Its way safer than the others.",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
