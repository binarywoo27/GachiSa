import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'category.dart';
import 'home.dart';
import 'my.dart';
import 'login.dart';

class WritePage extends StatefulWidget {
  _WritePage createState()=> _WritePage();
}

class _WritePage extends State<WritePage> {

  int _currentIndex = 3;

  String inputName;
  String inputPrice;
  String inputCategory;
  String inputWriter;
  String inputAddress;
  String inputAccept;
  String inputAmount;
  String inputLimit;
  String inputDescription;
  String inputDeadline;

  File _image;

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

  getGalleryImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _uploadImageToStorage(File uploadImg) async {
    FirebaseStorage store;
    final StorageReference pathReference = storageRef.child("images/"+(largestId + 1).toString()+".jpg");
    StorageUploadTask storageUploadTask = pathReference.putFile(uploadImg);
    await storageUploadTask.onComplete;
  }

  void createDoc(String writer, String address, String name, String category, int price, int accept, int amount, int limit, String deadline, String description) {

    var likers = [""];
    var buyers = [signedUser.uid];
    DateTime currDate = DateTime.now();
    int difference = int.parse(deadline.substring(0, deadline.length-1));
    DateTime newDate = currDate.add(Duration(days: difference));


    FirebaseFirestore.instance.collection('products').doc((largestId + 1).toString()).set({
      'writer' : writer,
      'address' : address,
      'id' : largestId + 1,
      'likers' : likers,
      'likes' : 0,
      'buyers' : buyers,
      'buys' : amount,
      'name': name,
      'category' : category,
      'price' : price,
      'accept' : accept,
      'limit' : limit,
      'deadline' : newDate,
      'description' : description,
      // 'producturl' :
      'regdate' : FieldValue.serverTimestamp(),
      'moddate' : FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    clearListFirst();
    makeProductList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: FutureBuilder(
          future: FirebaseFirestore.instance.collection('users').doc(signedUser.uid).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            final currUser = Users.fromSnapshot(snapshot.data);
            inputAddress = currUser.address;
            inputWriter = currUser.nickName;
            return FutureBuilder(
              future: FirebaseFirestore.instance.collection('products').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();
                return AppBar(
                  title: Text('등록', style: TextStyle(color: Colors.black),),
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  elevation: 1,
                  automaticallyImplyLeading: false,
                  actions: [
                    FlatButton(
                      child: Text('완료', style: TextStyle(color: Color.fromRGBO(93, 176, 117, 1)),) ,
                      onPressed: () {
                        createDoc(
                            inputWriter,
                            inputAddress,
                            inputName,
                            inputCategory,
                            int.parse(inputPrice),
                            int.parse(inputAccept),
                            int.parse(inputAmount),
                            int.parse(inputLimit),
                            inputDeadline,
                            inputDescription);
                        _uploadImageToStorage(_image);
                        Navigator.pop(context);
                      }
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').orderBy("id").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          return SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: Column(
                  children: [
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                child: Container(
                                  width: MediaQuery.of(context).size.width/2.5,
                                  height: MediaQuery.of(context).size.height/5,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(231, 231, 231, 1),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Color.fromRGBO(93, 176, 117, 0.3),
                                    child: SizedBox(
                                      child: _image != null ? Image.file(_image, fit: BoxFit.fill,) : Text("눌러서 사진 등록"),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  getGalleryImage();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          TextField(
                            onChanged: (value) {
                              inputName = value;
                            },
                            decoration: InputDecoration(
                              hintText: '상품명',
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 10,),
                          DropdownButton<String>(
                            isExpanded: true,
                            hint: Text("카테고리 선택"),
                            value: inputCategory,
                            icon: Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                inputCategory = newValue;
                              });
                            },
                            items: ['생필품', '식품', '의약품/건강', '패션/의류', '가전/디지털', '기타서비스']
                                .map<DropdownMenuItem<String>>
                              ((String value)  {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            onChanged: (value) {
                              inputPrice = value;
                            },
                            decoration: InputDecoration(
                              hintText: '가격 (숫자만 입력)',
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            onChanged: (value) {
                              inputAccept = value;
                            },
                            decoration: InputDecoration(
                              hintText: '모집 인원 (숫자만 입력)',
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            onChanged: (value) {
                              inputLimit = value;
                            },
                            decoration: InputDecoration(
                              hintText: '수량 제한 (숫자만 입력)',
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            onChanged: (value) {
                              inputAmount = value;
                            },
                            decoration: InputDecoration(
                              hintText: '본인 구매 수량 (숫자만 입력)',
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 10,),
                          DropdownButton<String>(
                            isExpanded: true,
                            hint: Text("기간 설정"),
                            value: inputDeadline,
                            icon: Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                inputDeadline = newValue;
                              });
                            },
                            items: ['1일', '2일', '3일', '5일', '7일', '10일']
                                .map<DropdownMenuItem<String>>
                              ((String value)  {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            onChanged: (value) {
                              inputDescription = value;
                            },
                            decoration: InputDecoration(
                              hintText: '내용(#으로 행 구분)',
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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