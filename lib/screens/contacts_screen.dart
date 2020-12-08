import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:coocoo/screens/ContactsHelpPage.dart';
import 'package:coocoo/screens/addFriends_screen.dart';
import 'package:coocoo/blocs/contacts/contacts_bloc.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/models/MyContact.dart';
import 'package:coocoo/widgets/ContactRowWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';

class ContactListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactListPageState();

  const ContactListPage();
}

class _ContactListPageState extends State<ContactListPage>
    with SingleTickerProviderStateMixin {
  ContactsBloc contactsBloc;
  final TextEditingController usernameController = TextEditingController();
  List<MyContact> contacts = [];
  UserDataFunction userDataFunction;
  bool refreshing = false;
  Color stuffColor = Colors.blueGrey[700];
  bool showSearchBar = false;
  int _selectedIndex = 0;

  AnimationController _animationController;
  Animation<double> animation;
  CurvedAnimation curve;

  final iconList = <IconData>[
    FontAwesomeIcons.addressBook,
    // Icons.contacts,
    // FontAwesomeIcons.solidAddressBook,
    FontAwesomeIcons.userFriends,
  ];

  @override
  void dispose() {
    usernameController.dispose();
    _animationController.dispose();
    // contactsBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    userDataFunction = UserDataFunction();
    contactsBloc = BlocProvider.of<ContactsBloc>(context);
    contactsBloc.add(FetchContactsEvent());
    super.initState();

    final systemTheme = SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    );
    SystemChrome.setSystemUIOverlayStyle(systemTheme);

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        1.0,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);

    Future.delayed(
      Duration(seconds: 1),
      () => _animationController.forward(),
    );
  }

  Widget _buildRefreshButton() {
    return InkWell(
      child: Icon(
        Icons.refresh,
        color: stuffColor,
      ),
      onTap: () async {
        setState(() {
          refreshing = true;
        });
        await userDataFunction.loadPhoneContactsV2(context);
        await Future.delayed(Duration(seconds: 8));
        contactsBloc.add(FetchContactsEvent());
        setState(() {
          refreshing = false;
        });
      },
    );
  }

  Widget _buildRefreshing() {
    return Container(
      width: 20.0,
      padding: EdgeInsets.symmetric(vertical: 18.0),
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildNormalAppBar(double screenWidth) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: stuffColor,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.white,
      title: Text(
        'Select Contact',
        style: TextStyle(
            fontSize: (screenWidth / perfectWidth) * 22.0, color: stuffColor),
      ),
      actions: <Widget>[
        refreshing ? _buildRefreshing() : _buildRefreshButton(),
        SizedBox(width: 25.0),
      ],
    );
  }

  void _onItemTapped(int ind) {
    setState(() {
      _selectedIndex = ind;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: _selectedIndex == 0 ? _buildNormalAppBar(screenWidth) : null,
        floatingActionButton: FloatingActionButton(
          elevation: 8,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.favorite,
            size: 40.0,
            color: Colors.black,
          ),
          onPressed: () {
            _animationController.reset();
            _animationController.forward();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar(
          elevation: 30.0,
          activeColor: Colors.black,
          splashColor: Colors.blueAccent,
          backgroundColor: Colors.white,
          icons: iconList,
          iconSize: 30.0,
          activeIndex: _selectedIndex,
          inactiveColor: Colors.grey,
          notchAndCornersAnimation: animation,
          splashSpeedInMilliseconds: 300,
          notchSmoothness: NotchSmoothness.softEdge,
          gapLocation: GapLocation.center,
          leftCornerRadius: 20,
          rightCornerRadius: 20,
          onTap: _onItemTapped,
        ),
        body: _selectedIndex == 0
            ? BlocBuilder<ContactsBloc, ContactsState>(
                builder: (context, state) {
                if (state is FetchingContactsState) {
                  print("Fetching Contacts");
                  return SizedBox(
                    height: (MediaQuery.of(context).size.height),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is FetchedContactsState) {
                  contacts = state.contacts;
                }
                return ListView(
                  children: <Widget>[
                    Column(
                      children: List.generate(
                          contacts.length,
                          (index) => ContactRowWidget(
                                contact: contacts[index],
                              )),
                    ),
                    Divider(thickness: 1.5),
                    SizedBox(height: (screenWidth / perfectWidth) * 20.0),
                    ListTile(
                      leading: Icon(
                        Icons.share,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Invite Friends',
                        style: TextStyle(
                          fontSize: (screenWidth / perfectWidth) * 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () => userDataFunction.onShare(context),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Contacts Help',
                        style: TextStyle(
                          fontSize: (screenWidth / perfectWidth) * 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactsHelpPage()));
                      },
                    ),
                  ],
                );
              })
            : AddFriendsScreen(),
      ),
    );
  }
}
