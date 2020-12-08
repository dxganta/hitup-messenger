import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coocoo/screens/otp_screen.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:coocoo/functions/UserDataFunction.dart';
import 'package:coocoo/stateProviders/number_state.dart';
import 'package:coocoo/utils/SharedObjects.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  Firestore _firestore = Firestore.instance;
  TextEditingController mobileNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserDataFunction userDataFunction = UserDataFunction();

  String countryCode = '91';

  // TODO: Handle the exception nicely here instead of just printing out the error
  final PhoneVerificationFailed _verificationFailed =
      (AuthException authException) {
    print(authException.message);
  };

  Future<bool> _showContinueDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
                'We will be verifying the phone number: +$countryCode ${mobileNumberController.text}'),
            content: Text('Is this OK, or would you like to edit the number?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('EDIT'),
              ),
              FlatButton(
                onPressed: () async {
                  context.read<NumberState>().setPhoneNumber(
                      "$countryCode${mobileNumberController.text}");
                  await SharedObjects.prefs
                      .setString(Constants.sessionCountryCode, countryCode);
                  await userDataFunction.verifyPhoneNumber(
                      context,
                      '+$countryCode' + mobileNumberController.text.toString(),
                      _verificationFailed);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => OTPScreen()));
                },
                child: Text('OK'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.0,
            ),
            Text("+${country.phoneCode} ${country.isoCode}"),
          ],
        ),
      );

  @override
  void dispose() {
    mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<NumberState>(
        create: (context) => NumberState(),
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 22.0),
              child: ListView(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            'Verify your phone number',
                            style: TextStyle(
                              color: Constants.textStuffColor,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          Text(
                            'HitUp Messenger will send and SMS message (carrier charges may apply) to verify'
                            ' your phone number. Enter your phone number.',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.0),
                          CountryPickerDropdown(
                            initialValue: 'IN',
                            itemBuilder: _buildDropdownItem,
//                                itemFilter:  ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
                            sortComparator: (Country a, Country b) =>
                                a.isoCode.compareTo(b.isoCode),
                            onValuePicked: (Country country) {
                              setState(() {
                                countryCode = country.phoneCode;
                              });
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 50.0),
                            child: TextFormField(
                              controller: mobileNumberController,
                              maxLengthEnforced: true,
                              maxLength: 10,
                              cursorColor: Constants.stuffColor,
                              style: TextStyle(fontSize: 20.0),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'\s+')) // no spaces allowed
                              ],
                              validator: (value) {
                                if (value.length != 10) {
                                  return 'Please enter 10 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      RaisedButton(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 30.0),
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
                            await _showContinueDialog();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
