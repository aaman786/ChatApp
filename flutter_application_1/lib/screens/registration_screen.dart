import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/rounded_button.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = "registration_screen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                    color: Colors.blue[900], fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your Email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(color: Colors.blue[900]),
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  title: 'Register',
                  colour: Colors.lightBlue,
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    // print(email);
                    // print(password);
                    try {
                      await _auth.createUserWithEmailAndPassword(
                          email: email, password: password);

                      Navigator.pushNamed(context, ChatScreen.id);

                      setState(() {
                        showSpinner = false;
                      });
                    } catch (e) {
                      print(e);
                      print("Exeption at registration_screen");
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
