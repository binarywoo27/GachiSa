import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  String inputName;
  String inputNickName;
  String inputPhone;
  String inputAddress = "한동대학교";
  int userCount = 0;

  void createUser(String name, String nickname, String phone, String address) {

    FirebaseFirestore.instance.collection('users').doc(signedUser.uid).set({
      'uid' : signedUser.uid,
      'name' : name,
      'nickname' : nickname,
      'phone' : phone,
      'address' : address,
      'regDate' : FieldValue.serverTimestamp(),
      'modDate' : FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: Column(
                  children: [
                    SizedBox(height: 100.0),
                    Container(
                      child: Center(
                        child: Text("회원가입", style: TextStyle(fontSize: 30,),),
                      ),
                    ),
                    SizedBox(height: 60.0),
                    Container(
                      padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (value) {
                              inputName = value;
                            },
                            decoration: InputDecoration(
                              hintText: '이름',
                            ),
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            onChanged: (value) {
                              inputNickName = value;
                            },
                            decoration: InputDecoration(
                              hintText: '닉네임',
                            ),
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            onChanged: (value) {
                              inputPhone = value;
                            },
                            decoration: InputDecoration(
                              hintText: '전화번호',
                            ),
                            style: TextStyle(color: Colors.black, fontSize: 18,),
                          ),
                          SizedBox(height: 20.0),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: inputAddress,
                            icon: Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                inputAddress = newValue;
                              });
                            },
                            items: ['한동대학교', '양덕']
                                .map<DropdownMenuItem<String>>
                              ((String value)  {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 80.0),
                          RaisedButton(
                            color: Color.fromRGBO(93, 176, 117, 1),
                            child: Text("Sign In", style: TextStyle(color: Colors.white),),
                            onPressed: () {
                              createUser(inputName, inputNickName, inputPhone, inputAddress);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}