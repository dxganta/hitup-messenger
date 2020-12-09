import 'package:coocoo/blocs/AddFriends/add_friends_bloc.dart';
import 'package:coocoo/blocs/chats/chat_bloc.dart';
import 'package:coocoo/blocs/contacts/contacts_bloc.dart';
import 'package:coocoo/blocs/timer/timer_bloc.dart';
import 'package:coocoo/screens/home_screen.dart';
import 'package:coocoo/splashscreen.dart';
import 'package:coocoo/stateProviders/number_state.dart';
import 'package:coocoo/stateProviders/profilePicUrlState.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'blocs/home/home_bloc.dart';
import 'stateProviders/mqtt_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedObjects.prefs = await CachedSharedPreferences.getInstance();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<ContactsBloc>(
        create: (context) => ContactsBloc(),
      ),
      BlocProvider<ChatBloc>(
        create: (context) => ChatBloc(),
      ),
      BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(),
      ),
      BlocProvider<AddFriendsBloc>(
        create: (context) => AddFriendsBloc(),
      ),
      BlocProvider<TimerBloc>(
        create: (context) => TimerBloc(),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MQTTState>(create: (context) => MQTTState()),
        ChangeNotifierProvider<NumberState>(
          create: (context) => NumberState(),
        ),
        ChangeNotifierProvider<ProfilePicUrlState>(
            create: (context) => ProfilePicUrlState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HitUp Messenger',
        routes: {
          '/homeScreen': (context) => HomeScreen(),
        },
        theme: ThemeData(
          primaryColor: Colors.white,
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

//Feature Ideas

//TODO: Mood of a user
//TODO: Online Offline...but only to the people whom I wanna show if I am online
//TODO: whether the user is active or not, i.e if she is inside your chat window or is she chatting with someone else
