import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/functions/BaseFunctions.dart';
import 'package:coocoo/managers/mqtt_manager.dart';
import 'package:coocoo/stateProviders/mqtt_state.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class MQTTFunction extends BaseMQTTFunction {
  MQTTManager _manager;
  String loggedInUser;

  @override
  Future<void> connect(BuildContext context) async {
    loggedInUser = SharedObjects.prefs.getString(Constants.sessionUid);
    _manager = context.read<MQTTState>().manager;

    final String password = "S8x${loggedInUser.substring(1, 6)}S,.@";

    if (_manager == null) {
      _manager = MQTTManager(
        serverAddress: "13.127.199.45",
        clientName: loggedInUser,
        context: context,
      );

      _manager.initializeMQTTClient();

      // also set the mqtt_manager to the provider
      context.read<MQTTState>().setNewManager(_manager);
      print(_manager);
    }

    print("Connecting to server");
    await _manager.connect(loggedInUser, password);
  }

  @override
  void dispose() {}

  @override
  void disconnect() {
    if (_manager != null) {
      _manager.disconnect();
    }
  }
}
