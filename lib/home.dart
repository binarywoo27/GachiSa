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

import 'login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'my.dart';
import 'write.dart';
import 'category.dart';
import 'detail.dart';


final FirebaseStorage storage = FirebaseStorage.instance;
final StorageReference storageRef = storage.ref();
final List<Record> productitem = [];

class ScreenArguments {
  final String name;
  ScreenArguments(this.name);
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
    time = '마감 ' + diff.inDays.toString() + '일 전';
  } else if(diff.inHours > 0){
    time = '마감 ' + diff.inHours.toString() + '시간 전';
  } else {
    time = '잠시 후 마감';
  }
  return time;
}

int largestId = 0;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var formatter = new NumberFormat("#,###");
  int _currentIndex = 2;

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

  @override
  void initState() {
    super.initState();
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(signedUser.uid).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return LinearProgressIndicator();
        final currUser = Users.fromSnapshot(snapshot.data);
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').where("address", isEqualTo: currUser.address).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            return _buildList(context, snapshot.data.docs);
          },
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {

    return GridView.count(
      primary: false,
      mainAxisSpacing: 20.0,
      crossAxisCount: 1,
      padding: EdgeInsets.all(20.0),
      childAspectRatio: 9.0/9.1,
      shrinkWrap: true,
      children: snapshot.map((data) => _buildGridCards(context, data)).toList(),
    );
  }

  Widget _buildGridCards(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    if(calculateDueDate(record.deadline) == "마감") {
      FirebaseFirestore.instance.collection('endProducts').doc((record.id).toString()).set({
        'writer' : record.writer,
        'address' : record.address,
        'id' : record.id,
        'likers' : record.likers,
        'likes' : 0,
        'buyers' : record.buyers,
        'buys' : 1,
        'name': record.name,
        'category' : record.category,
        'price' : record.price,
        'accept' : record.accept,
        'limit' : record.limit,
        'deadline' : record.deadline,
        'description' : record.description,
        'regdate' : FieldValue.serverTimestamp(),
        'moddate' : FieldValue.serverTimestamp(),
      });
      record.reference.delete();
    }
    final String imgPath = "images/" + record.id.toString() +".jpg";
    final StorageReference pathReference = storageRef.child(imgPath);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return FutureBuilder(
      future: pathReference.getDownloadURL(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        if(record.id >= largestId) {
          largestId = record.id;
        }

        return Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                    ]
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            Text(
                              " " + record.likes.toString() + "     ",
                              style: TextStyle(color: Colors.redAccent,),
                            ),
                            Icon(
                              Icons.shopping_cart,
                              color: Color.fromRGBO(93, 176, 117, 1),
                              size: 18,
                            ),
                            Text(
                              " " + record.buys.toString() + "/" + record.accept.toString(),
                              style: TextStyle(color: Color.fromRGBO(93, 176, 117, 1)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        record.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        formatter.format(record.price).substring(1, formatter.format(record.price).indexOf(".")) + "원",
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            calculateDueDate(record.deadline),
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          RaisedButton(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            color: Color.fromRGBO(93, 176, 117, 1),
                            child: Text(
                              '자세히 보기',
                              style: TextStyle(fontSize: 14, color: Colors.white,),
                            ),
                            onPressed: () {
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    clearListFirst();
    makeProductList();
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(signedUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        final currUser = Users.fromSnapshot(snapshot.data);
        return Scaffold(
          appBar: AppBar(
            title: Row(children: [Text(currUser.address, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),), Text(" 배송 상품", style: TextStyle(color: Colors.black, fontSize: 16),)],),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 1,
          ),
          body: Column(
            children: [
              Expanded(
                child: _buildBody(context),
              ),
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
                icon: Icon(Icons.category),
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
      },
    );
  }
}

class Record {
  final int id;
  final String name;
  final int price;
  final String description;
  final int likes;
  final List<dynamic> likers;
  final int buys;
  final List<dynamic> buyers;
  final String address;
  final String category;
  final String writer;
  final int accept;
  final int limit;
  final Timestamp deadline;
  final Timestamp regdate;
  final Timestamp moddate;
  final String url;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['price'] != null),
        assert(map['description'] != null),
        regdate = map['regdate'],
        moddate = map['moddate'],
        deadline = map['deadline'],
        id = map['id'],
        name = map['name'],
        price = map['price'],
        description = map['description'],
        likes = map['likes'],
        likers = map['likers'],
        buys = map['buys'],
        buyers = map['buyers'],
        address = map['address'],
        accept = map['accept'],
        limit = map['limit'],
        url = map['url'],
        writer = map['writer'],
        category = map['category'];


  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "$reference";
}

class Users {
  final String uid;
  final String name;
  final String nickName;
  final String phone;
  final String address;
  final List<dynamic> buyProducts;
  final List<dynamic> likeProducts;
  final Timestamp regdate;
  final Timestamp moddate;
  final DocumentReference reference;

  Users.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['nickname'] != null),
        assert(map['phone'] != null),
        assert(map['address'] != null),
        uid = map['uid'],
        name = map['name'],
        nickName = map['nickname'],
        phone = map['phone'],
        address = map['address'],
        buyProducts = map['buy_product'],
        likeProducts = map['like_product'],
        regdate = map['regdate'],
        moddate = map['moddate'];

  Users.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}

void clearListFirst() {
  productitem.clear();
}

void makeProductList() {
  final Query products = FirebaseFirestore.instance.collection('products');
  products.get().then((snapshot) {
    snapshot.docs.forEach((doc){
      final product = Record.fromSnapshot(doc);
      productitem.add(product);
    });
  });
}

List<Record> loadProductItem() {
  return productitem;
}

class ProductItemsSearch extends SearchDelegate<Record> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () {
      // when cross button is clicked, the search bar will become blank.
      query = "";
    },)];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
      // as off now it is null, so just turning off the search bar will be done. this can be changed later.
      close(context, null);
    }, );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final mylist = query.isEmpty? loadProductItem() : loadProductItem().where((p) => p.name.startsWith(query)).toList();

    return mylist.isEmpty? Text('  아직 등록된 상품이 없습니다!\n  등록하기 버튼을 눌러 새로 등록해주세요! :)',
      style: TextStyle(fontSize: 18),) :

    ListView.builder(
        itemCount: mylist.length,
        itemBuilder: (context, index) {
          final Record listitem = mylist[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(),
                  settings: RouteSettings(
                    arguments: ScreenArguments(
                      listitem.toString(),
                    ),
                  ),
                ),
              );
            },
            title : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listitem.name, style: TextStyle(fontSize: 20),),
                Text(listitem.category, style: TextStyle(color: Colors.grey)),
                Divider(),
              ],
            ),);
        });
  }
}