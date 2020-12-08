import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/screens/enter_name_screen.dart';
import 'package:coocoo/blocs/timer/timer_bloc.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/functions/MQTTFunction.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/screens/home_screen.dart';
import 'package:coocoo/stateProviders/number_state.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController otpController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  SharedPreferences loginData;

  bool isVerifying = false;
  UserDataFunction userDataFunction;
  MQTTFunction mqttFunction;
  bool showSpinner = false;
  TimerBloc timerBLoc;
  String minutesStr = '00';
  String secondsStr = Constants.resendOtpTime.toString();

  bool resendOtpSwitch = false;

  // TODO: Handle the exception nicely here instead of just printing out the error
  final PhoneVerificationFailed _verificationFailed =
      (AuthException authException) {
    print(authException.message);
  };

  Future<bool> _showWrongOTPDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('The code you entered was not correct'),
            content: Text('Please enter the correct code!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('TRY AGAIN'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _signInWithPhoneNumber(String smsCode) async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: context.read<NumberState>().otp, smsCode: smsCode);

    await _auth.signInWithCredential(_authCredential).catchError((error) {
      _showWrongOTPDialog();
      print(error);
    }).then((AuthResult _authResult) async {
      if (_authResult != null) {
        setState(() {
          isVerifying = true;
        });
        FirebaseUser currUser = _authResult.user;
        print(currUser.phoneNumber);
        String myPhoneNumber = currUser.phoneNumber.substring(1);
        DocumentReference ref = _firestore.collection('users').document(
            myPhoneNumber); //reference of the user's document node in database/users. This node is created using uid

        await SharedObjects.prefs.setBool('login', false);
        await SharedObjects.prefs
            .setString(Constants.sessionUid, myPhoneNumber);

        ref.get().then((doc) async {
          if (doc.exists) {
            String profilePhotoUrl = doc.data['photoUrl'];
            String username = doc.data['username'];
            SharedObjects.prefs
                .setString(Constants.sessionProfilePictureUrl, profilePhotoUrl);
            SharedObjects.prefs.setString(Constants.sessionUsername, username);

            PermissionStatus currPermission =
                await userDataFunction.askContactPermissions();

            if (currPermission == PermissionStatus.granted) {
              await userDataFunction.loadPhoneContactsV2(context);
              isVerifying = false;
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            } else {
              setState(() {
                isVerifying = false;
              });
            }
          } else {
            var data = {
              //add details
              'phoneNumber': myPhoneNumber,
            };
            ref.setData(data, merge: true);
            isVerifying = false;
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => EnterName()));
          }
        });
      }
    });
  }

  Widget _buildOTPScreen() {
    return ChangeNotifierProvider<NumberState>(
      create: (context) => NumberState(),
      child: Form(
        key: _formKey,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 25.0),
            child: ListView(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          'Verify +${context.watch<NumberState>().phoneNumber}',
                          style: TextStyle(
                            color: Constants.textStuffColor,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Text(
                          "Please enter the 6-digit code sent to +${context.watch<NumberState>().phoneNumber}",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.0),
                          child: TextFormField(
                            controller: otpController,
                            maxLengthEnforced: true,
                            maxLength: 6,
                            cursorColor: Constants.stuffColor,
                            style: TextStyle(fontSize: 18.0),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Enter 6-digit code',
                            ),
                          ),
                        ),
                      ],
                    ),
                    RaisedButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      color: Constants.stuffColor,
                      child: Text(
                        'VERIFY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        await _signInWithPhoneNumber(
                            otpController.text.toString());
                        setState(() {
                          showSpinner = false;
                        });
                      },
                    ),
                    SizedBox(height: 15.0),
                    Card(
                      elevation: 5.0,
                      child: ListTile(
                          onTap: resendOtpSwitch
                              ? () {
                                  timerBLoc.add(StartTimerEvent());
                                  setState(() {
                                    resendOtpSwitch = false;
                                  });
                                  String phoneNum =
                                      context.read<NumberState>().phoneNumber;
                                  userDataFunction.verifyPhoneNumber(context,
                                      '+$phoneNum', _verificationFailed);
                                }
                              : () {},
                          leading: Icon(Icons.message,
                              color:
                                  resendOtpSwitch ? Colors.black : Colors.grey),
                          title: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color:
                                  resendOtpSwitch ? Colors.black : Colors.grey,
                            ),
                          ),
                          trailing: BlocListener<TimerBloc, TimerState>(
                            listener: (context, state) {
                              if (state is TimerRunInProgressState) {
                                setState(() {
                                  secondsStr = (state.newTick % 60)
                                      .floor()
                                      .toString()
                                      .padLeft(2, '0');
                                });
                              }

                              if (state is TimerStoppedState) {
                                setState(() {
                                  resendOtpSwitch = true;
                                });
                              }
                            },
                            child: Text(
                              '$minutesStr:$secondsStr',
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingScreen() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void initState() {
    userDataFunction = UserDataFunction();
    timerBLoc = BlocProvider.of<TimerBloc>(context);
    timerBLoc.add(StartTimerEvent());
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    timerBLoc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isVerifying || showSpinner ? _loadingScreen() : _buildOTPScreen(),
    );
  }
}
