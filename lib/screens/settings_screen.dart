import 'package:coocoo/screens/account_screen.dart';
import 'package:coocoo/screens/help_screen.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/widgets/SettingsTile.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final UserDataFunction userDataFunction = UserDataFunction();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          SettingsTile(
            icon: Icons.settings,
            title: 'Account',
            onPress: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AccountScreen()));
            },
          ),
          SettingsTile(
            icon: Icons.help_outline,
            title: 'Help',
            onPress: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HelpScreen()));
            },
          ),
          SettingsTile(
            icon: Icons.supervisor_account,
            title: 'Invite a Friend',
            onPress: () => userDataFunction.onShare(context),
          ),
        ],
      ),
    );
  }
}
