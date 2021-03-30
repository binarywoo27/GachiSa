import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signin.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
User signedUser;
String isSigned;

Future<void> signInWithGoogle() async {
  await Firebase.initializeApp();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult = await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: ' + user.uid);
    signedUser = user;
  }
}

Future<void> _getUser() async {
  final get = await FirebaseFirestore.instance.collection('users').doc(signedUser.uid).get();
  if(get.data() == null) {
    isSigned = "No";
  }
  else {
    isSigned = "Yes";
  }
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
  print("User Signed Out");
}


class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          children: <Widget>[
            SizedBox(height: 210.0),
            Column(
              children: <Widget>[
                SizedBox(height: 16.0),
                Text('APP NAME', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 120.0),
            SizedBox(
              child: FlatButton(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          'G',
                          style:TextStyle(color: Colors.white, fontSize: 30),
                        ),
                        color: Color.fromRGBO(93, 176, 117, 1),
                        height: 45,
                        alignment: Alignment.center,
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        child: Text(
                          "Google로 로그인",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color.fromRGBO(93, 176, 117, 0.7),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  signInWithGoogle().then((result) {

                    _getUser().then((result) {
                      if(isSigned == "Yes") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                          HomePage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              SignInPage()),
                        );
                      }
                    });
                  });
                },
              ),
            ),
            SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}
