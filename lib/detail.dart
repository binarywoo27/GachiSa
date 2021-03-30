import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'login.dart';

int currPrice = 0;
bool isLiked = false;

String getId(String arg) {
  String newId = arg.substring(arg.indexOf('/')+1, arg.indexOf(')'));
  return newId;
}

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  var formatter = new NumberFormat("#,###");
  String inputCount = "1";


  @override
  Widget build(BuildContext context) {

    bool isAuthor = false;
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    final String currId = getId(args.name);

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('products').doc(currId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          final currRecord = Record.fromSnapshot(snapshot.data);
          final String imgPath = "images/" + currRecord.id.toString() +".jpg";
          final pathReference = storageRef.child(imgPath);
          currPrice = currRecord.price;
          return StreamBuilder(
            stream: pathReference.getDownloadURL().asStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(231, 231, 231, 1),
                                  ),
                                  child: Image(
                                    image: NetworkImage(snapshot.data.toString()),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  color: Colors.black,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ]
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currRecord.name,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                                ),
                                SizedBox(),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(currRecord.category, style: TextStyle(color: Colors.grey, fontSize: 16),),
                                    SizedBox(width: 10,),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    Text(
                                      " " + currRecord.likes.toString(),
                                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                                    ),
                                    SizedBox(width: 10,),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart,
                                          color: Color.fromRGBO(93, 176, 117, 1),
                                          size: 20,
                                        ),
                                        Text(
                                          " " + currRecord.buys.toString() + "/" + currRecord.accept.toString(),
                                          style: TextStyle(color: Color.fromRGBO(93, 176, 117, 1), fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(height: 15, color: Colors.black),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(),
                                    Text(currRecord.writer, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.alarm, color: Colors.grey, size: 20,),
                                    SizedBox(width: 5,),
                                    Text(calculateDueDate(currRecord.deadline), style: TextStyle(color: Colors.grey, fontSize: 16),),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(currRecord.address, style: TextStyle(fontSize: 16, color: Colors.grey),),
                                Text("수량 제한  " + currRecord.limit.toString(), style: TextStyle(fontSize: 16, color: Colors.grey),),
                              ],
                            ),
                            SizedBox(height: 50,),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(currRecord.description.replaceAll("#", "\n"), style: TextStyle(fontSize: 16),),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          );
        }
      ),
      bottomSheet: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('products').doc(currId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          final currRecord = Record.fromSnapshot(snapshot.data);
          int limit = currRecord.limit;
          List<String> counts = [];
          while(limit > 0) {
            counts.add(limit.toString());
            limit -= 1;
          }
          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(signedUser.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              final currUser = Users.fromSnapshot(snapshot.data);
              if(currUser.nickName == currRecord.writer) {
                isAuthor = true;
              }
              return Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: !currRecord.likers.contains(signedUser.uid) ? Icon(Icons.favorite_border, size: 30,) : Icon(Icons.favorite, size: 30, color: Colors.redAccent,),
                          onPressed: () {
                            if(!currRecord.likers.contains(signedUser.uid)) {
                              currRecord.reference.update({'likes':FieldValue.increment(1), 'likers':FieldValue.arrayUnion([signedUser.uid])});
                              //currUser.reference.update({'like_product':FieldValue.arrayUnion([getId(currRecord.toString())])});
                            } else {
                              currRecord.reference.update({'likes':FieldValue.increment(-1), 'likers':FieldValue.arrayRemove([signedUser.uid])});
                              //currUser.reference.update({'like_product':FieldValue.arrayRemove([getId(currRecord.toString())])});
                            }
                          },
                        ),
                        Text(
                          formatter.format(currRecord.price).substring(1, formatter.format(currRecord.price).indexOf(".")) + "원",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    RaisedButton(
                      color: !currRecord.buyers.contains(signedUser.uid) ? Color.fromRGBO(93, 176, 117, 1) : Colors.black12,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: !currRecord.buyers.contains(signedUser.uid) ? Text('참여하기', style: TextStyle(color: Colors.white, fontSize: 16),) : (currUser.address == currRecord.address ? Text('참여중', style: TextStyle(color: Colors.white, fontSize: 16),) : Text('참여불가', style: TextStyle(color: Colors.white, fontSize: 16),)),
                      onPressed: () {
                        if(!currRecord.buyers.contains(signedUser.uid)) {
                          if(currRecord.address == currUser.address) {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return FutureBuilder(
                                      future: FirebaseFirestore.instance.collection(
                                          'products').doc(currId).get(),
                                      builder: (context, snapshot) {
                                        return StatefulBuilder(
                                            builder: (BuildContext context, StateSetter mystate) {
                                              return SingleChildScrollView(
                                                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "수량 선택 ",
                                                          style: TextStyle(fontSize: 16),
                                                        ),
                                                        SizedBox(width: 25,),
                                                        DropdownButton<String>(
                                                          value: inputCount,
                                                          icon: Icon(Icons.arrow_drop_down),
                                                          elevation: 16,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                          ),
                                                          onChanged: (String newValue) {
                                                            mystate(() {
                                                              inputCount = newValue;
                                                            });
                                                          },
                                                          items: counts
                                                              .map<DropdownMenuItem<String>>
                                                            ((String value)  {
                                                            return DropdownMenuItem<String>(
                                                              value: value,
                                                              child: Text(value),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ],
                                                    ),
                                                    RaisedButton(
                                                      color: Color.fromRGBO(93, 176, 117, 1),
                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      child: Text('참여하기', style: TextStyle(color: Colors.white, fontSize: 16),),
                                                      onPressed: () {
                                                        currRecord.reference.update({'buys':FieldValue.increment(int.parse(inputCount))});
                                                        for(int i = 0; i < int.parse(inputCount); i++) {
                                                          currRecord.reference.update({'buyers':FieldValue.arrayUnion([signedUser.uid]),});
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                        );
                                      }
                                  );
                                }
                            );
                          }
                        }
                      },
                    )
                  ],
                ),
              );
            },
          );
        }
      ),
    );
  }
}