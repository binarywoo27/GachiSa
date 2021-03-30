import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'category.dart';
import 'write.dart';
import 'detail.dart';

class MyPage extends StatefulWidget {
  _MyPage createState()=> _MyPage();
}

class _MyPage extends State<MyPage> {
  int _currentIndex = 4;

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
  Widget build(BuildContext context) {
    clearListFirst();
    makeProductList();
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(signedUser.uid).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return LinearProgressIndicator();
          final currUser = Users.fromSnapshot(snapshot.data);

          return Container(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 40,),
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(50),
                        color: Color.fromRGBO(93, 176, 117, 1),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, bottom: 40,),
                      height: 75,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10,),
                            height: 45,
                            child: Text(currUser.nickName, style: TextStyle(fontSize: 18),),
                          ),
                          Container(
                            height: 30,
                            child: Text(currUser.name,style: TextStyle(fontSize: 14),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 2, color: Colors.black,),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          FlatButton(
                            child: Row(
                              children: [
                                Icon(Icons.shopping_basket, color: Color.fromRGBO(93, 176, 117, 1),),
                                SizedBox(width: 20,),
                                Text("구매 내역", style: TextStyle(color: Colors.black, fontSize: 18),),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    OrderedPage()),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          FlatButton(
                            child: Row(
                              children: [
                                Icon(Icons.favorite, color: Color.fromRGBO(93, 176, 117, 1),),
                                SizedBox(width: 20,),
                                Text("관심 목록", style: TextStyle(color: Colors.black, fontSize: 18),),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    FavoritePage()),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          FlatButton(
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Color.fromRGBO(93, 176, 117, 1),),
                                SizedBox(width: 20,),
                                Text("정보 변경", style: TextStyle(color: Colors.black, fontSize: 18),),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                InfoPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
    );
  }
}

class InfoPage extends StatefulWidget {
  _InfoPage createState()=> _InfoPage();
}

class _InfoPage extends State<InfoPage> {

  void editUser(String name, String nickname, String phone, String address) {

    FirebaseFirestore.instance.collection('users').doc(signedUser.uid).set({
      'name' : name,
      'nickname' : nickname,
      'phone' : phone,
      'address' : address,
      'modDate' : FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    clearListFirst();
    makeProductList();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("개인정보 변경", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(signedUser.uid).get(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return LinearProgressIndicator();
          final currUser = Users.fromSnapshot(snapshot.data);
          String inputName = currUser.name;
          String inputNickName = currUser.nickName;
          String inputPhone = currUser.phone;
          String inputAddress = currUser.address;
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter mystate) {
              return SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    child: Column(
                      children: [
                        SizedBox(height: 60.0),
                        Container(
                          padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                          child: Column(
                            children: [
                              TextField(
                                onChanged: (value) {
                                  inputName = value;
                                },
                                style: TextStyle(fontSize: 18, color: Colors.black),
                                controller: TextEditingController()..text = inputName,
                              ),
                              SizedBox(height: 20.0),
                              TextField(
                                onChanged: (value) {
                                  inputNickName = value;
                                },
                                style: TextStyle(fontSize: 18, color: Colors.black),
                                controller: TextEditingController()..text = inputNickName,
                              ),
                              SizedBox(height: 20.0),
                              TextField(
                                onChanged: (value) {
                                  inputPhone = value;
                                },
                                style: TextStyle(color: Colors.black, fontSize: 18,),
                                controller: TextEditingController()..text = inputPhone,
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
                                  mystate(() {
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
                                child: Text("변경하기", style: TextStyle(color: Colors.white),),
                                onPressed: () {
                                  editUser(inputName, inputNickName, inputPhone, inputAddress);
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
            }
          );
        },
      ),
    );
  }
}

class FavoritePage extends StatefulWidget {
  _FavoritePage createState()=> _FavoritePage();
}

class _FavoritePage extends State<FavoritePage> {

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    final String imgPath = "images/" + record.id.toString() +".jpg";
    final StorageReference pathReference = storage.ref().child(imgPath);

    return FutureBuilder(
      future: pathReference.getDownloadURL(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return record.likers.contains(signedUser.uid) ? Padding(
          key: ValueKey(record.name),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GestureDetector(
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
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(93, 176, 117, 1)),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ListTile(
                title: Container(
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 50,
                          child: Image(
                            image: NetworkImage(snapshot.data.toString()),
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(record.name),
                        ),
                      ],
                    )
                ),
                trailing: Container(
                  alignment: Alignment.centerRight,
                  width: 30,
                  child: GestureDetector(
                    onTap: () {
                      record.reference.update({'likes':FieldValue.increment(-1), 'likers':FieldValue.arrayRemove([signedUser.uid])});
                      //currUser.reference.update({'like_product':FieldValue.arrayRemove([getId(currRecord.toString())])});
                    },
                    child: Icon(Icons.delete_outline,color: Color.fromRGBO(93, 176, 117, 1)),
                  ),
                ),
              ),
            ),
          ),
        ) : SizedBox();
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('관심 목록', style: TextStyle(color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:  _buildBody(context),
    );
  }
}

class OrderedPage extends StatefulWidget {
  _OrderedPage createState()=> _OrderedPage();
}

class _OrderedPage extends State<OrderedPage> {

  String dropdownValue = '모집중';

  void showAlertDialog(BuildContext context, DocumentReference record, String now, String total, String address, Timestamp deadline, int buys, int accept) async {
    var today = DateTime.now();
    var date = deadline.toDate();
    var diff = date.difference(today);
    var status = "";
    if(diff.inMilliseconds >= 0) {
      status = "모집중";
    } else {
      if(now == total) {
        status = "주문 완료";
      } else {
        status = "취소";
      }
    }

    var duedate = date.toString().substring(0, 16);
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주문 현황', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(93, 176, 117, 1),),),
          content: Container(
            alignment: Alignment.centerLeft,
            width: 300,
            height: 180,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("상태", style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 20,),
                          Text("인원 현황", style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 20,),
                          Text("마감 날짜", style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 20,),
                          Text("배송지", style: TextStyle(fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    SizedBox(width: 30,),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status, style: TextStyle(color: calculateDueDate(deadline) != '마감' ? Color.fromRGBO(93, 176, 117, 1) : (buys == accept ? Colors.grey : Colors.redAccent), fontWeight: FontWeight.bold),),
                          SizedBox(height: 25,),
                          Text(now + " / " + total),
                          SizedBox(height: 25,),
                          Text(duedate),
                          SizedBox(height: 25,),
                          Text(address),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Color.fromRGBO(93, 176, 117, 1),
              child: Text('확인', style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.pop(context, "Cancel");
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildEndBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('endProducts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      //padding: const EdgeInsets.only(top: 40.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    final String imgPath = "images/" + record.id.toString() +".jpg";
    final StorageReference pathReference = storage.ref().child(imgPath);

    return FutureBuilder(
        future: pathReference.getDownloadURL(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return record.buyers.contains(signedUser.uid) ? Padding(
            key: ValueKey(record.name),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () {
                showAlertDialog(context, record.reference, record.buys.toString(), record.accept.toString(), record.address, record.deadline, record.buys, record.accept);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: calculateDueDate(record.deadline) != '마감' ? Color.fromRGBO(93, 176, 117, 1) : (record.buys == record.accept ? Colors.grey : Colors.redAccent),),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: ListTile(
                  title: Container(
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 50,
                            child: Image(
                              image: NetworkImage(snapshot.data.toString()),
                              fit: BoxFit.fill,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text(record.name),
                          ),
                        ],
                      )
                  ),
                  trailing: Container(
                    alignment: Alignment.centerRight,
                    width: 60,
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: calculateDueDate(record.deadline) != '마감' ? Color.fromRGBO(93, 176, 117, 1) : (record.buys == record.accept ? Colors.grey : Colors.redAccent),
                          size: 16,
                        ),
                        Text(
                          " " + record.buys.toString() + "/" + record.accept.toString(),
                          style: TextStyle(color: calculateDueDate(record.deadline) != '마감' ? Color.fromRGBO(93, 176, 117, 1) : (record.buys == record.accept ? Colors.grey : Colors.redAccent), fontSize: 14),
                        ),
                      ],
                    )
                  ),
                ),
              ),
            )
          ) : SizedBox();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('구매 내역', style: TextStyle(color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                children: [
                  DropdownButton<String>(
                    iconEnabledColor: Color.fromRGBO(93, 176, 117, 1),
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: ['모집중', '종료']
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
            ),
            Flexible(
              child: dropdownValue == '모집중' ? _buildBody(context) : _buildEndBody(context),
            ),
          ],
        ),
      )
    );
  }
}