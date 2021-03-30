// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//import 'dart:html';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'my.dart';
import 'write.dart';
import 'category.dart';
import 'home.dart';
import 'detail.dart';


final FirebaseStorage storage = FirebaseStorage.instance;
final StorageReference storageRef = storage.ref();

class CatResultPage extends StatefulWidget {
  final String name;
  CatResultPage({Key key, @required this.name}) : super(key: key);

  @override
  _CatResultPageState createState() => _CatResultPageState(name);
}

class _CatResultPageState extends State<CatResultPage> {
  final String name;
  _CatResultPageState(this.name);

  int count = 0;
  var formatter = new NumberFormat("#,###");
  int _currentIndex = 0;

  final List<Widget> _children = [CategoryPage(), HomePage(), HomePage(), WritePage(), MyPage()];
  void _onTap(int index) {
    if(index != 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
        _children[index]),
      );
    } else {
      showSearch(context: context, delegate: ProductItemsSearch());
    }
  }

  String calculateDueDate(Timestamp deadline) {
    var now = DateTime.now();
    var date = deadline.toDate();
    var diff = date.difference(now);
    String time = '';
    if(diff.inSeconds <= 0) {
      time = "마감";
    }
    else if (diff.inDays > 0) {
      time = '마감 ' + diff.inDays.toString() + '일 남음';
    } else if(diff.inHours > 0){
      time = '마감 ' + diff.inHours.toString() + '시간 남음';
    } else {
      time = '잠시 후 마감';
    }
    return time;
  }

  @override
  void initState() {

    super.initState();
  }

  Widget _buildBody(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').where("category", isEqualTo: name).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    count = snapshot.map((data) => _buildGridCards(context, data)).toList().length;
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16.0),
      childAspectRatio: 9.0/9.0,
      children: snapshot.map((data) => _buildGridCards(context, data)).toList(),
    );
  }

  Widget _buildGridCards(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    final String imgPath = "images/" + record.id.toString() +".jpg";
    final StorageReference pathReference = storageRef.child(imgPath);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return FutureBuilder(
      future: pathReference.getDownloadURL(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return calculateDueDate(record.deadline) != "마감" ? Card(
          clipBehavior: Clip.antiAlias,
          child: new InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(),
                  settings: RouteSettings(
                    arguments: ScreenArguments(
                      record.toString(),
                    ),
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 19 / 12,
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
                          color: Colors.black,
                          width: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 10,
                              ),
                              Text(
                                " " + record.likes.toString() + "  ",
                                style: TextStyle(color: Colors.redAccent,),
                              ),
                              Icon(
                                Icons.shopping_cart,
                                color: Color.fromRGBO(93, 176, 117, 1),
                                size: 10,
                              ),
                              Text(
                                " " + record.buys.toString() + "/" + record.accept.toString() + "  ",
                                style: TextStyle(color: Color.fromRGBO(93, 176, 117, 1)),
                              ),
                            ],
                          ),
                        ),
                      ]
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // 제품 이름만 12 폰트로 맞춤...
                        Text(
                          record.name,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1,
                        ),
                        // SizedBox(height: 8.0),
                        Text(
                          formatter.format(record.price).substring(1, formatter.format(record.price).indexOf(".")) + "원",
                          style: TextStyle(fontSize: 10),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              calculateDueDate(record.deadline),
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) : SizedBox();
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    clearListFirst();
    makeProductList();
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(name, style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBody(context),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        fixedColor: Color.fromRGBO(93, 176, 117, 1),
        onTap: _onTap,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.category),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CategoryPage()),
                );
              },
            ),
            title: Text('Category'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            title: Text('Register'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('MyPage'),
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
