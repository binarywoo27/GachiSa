import 'package:flutter/material.dart';

import 'catresult.dart';
import 'my.dart';
import 'write.dart';
import 'home.dart';


class Choice {
  const Choice({this.name, this.image});
  final String name;
  final String image;
}

const List<Choice> choices = const <Choice>[
  const Choice(name: '생필품', image: 'https://firebasestorage.googleapis.com/v0/b/final-project-firebase-5f7a7.appspot.com/o/images%2Fproducts.jpg?alt=media&token=2cf0fbf6-b0ca-4e05-95bb-0dfd247ab2cf'),
  const Choice(name: '식품', image: 'https://firebasestorage.googleapis.com/v0/b/final-project-firebase-5f7a7.appspot.com/o/images%2Ffood.jpg?alt=media&token=eed31f12-10b7-48c6-b094-8f570cade7df'),
  const Choice(name: '의약품/건강', image: 'https://firebasestorage.googleapis.com/v0/b/final-project-firebase-5f7a7.appspot.com/o/images%2Fmedicine.jpg?alt=media&token=4d7da1d4-deb6-4a90-9311-d8cc7cdde671'),
  const Choice(name: '패션/의류', image: 'https://firebasestorage.googleapis.com/v0/b/final-project-firebase-5f7a7.appspot.com/o/images%2Fclothing.jpg?alt=media&token=d10a12d9-2dfb-42b5-a266-daf21668d81f'),
  const Choice(name: '가전/디지털', image: 'https://firebasestorage.googleapis.com/v0/b/final-project-firebase-5f7a7.appspot.com/o/images%2Felectronics.jpg?alt=media&token=af46d0c9-4101-46b3-baf5-c9f108d43d91'),
  const Choice(name: '기타서비스', image: 'https://firebasestorage.googleapis.com/v0/b/final-project-firebase-5f7a7.appspot.com/o/images%2Fservices.jpg?alt=media&token=c6845d7f-834a-463c-a7ca-d7ca8192af43'),
];


class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

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

  @override
  Widget build(BuildContext context) {
    clearListFirst();
    makeProductList();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text("카테고리", style: TextStyle(color: Colors.black),),
          centerTitle: true,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
          child: Column(
            children: [
              SizedBox(height: 70.0),
              GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 8.0,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: EdgeInsets.all(2.0),
                  childAspectRatio: 8.0 / 9.0,
                  children: List.generate(choices.length, (index) {
                    // return Container(color: Colors.green,);
                    return SelectCard(choice: choices[index]);
                  })),
            ],
          ),
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
      ),
    );
  }
}

class SelectCard extends StatefulWidget {
  final Choice choice;
  SelectCard({this.choice});

  @override
  _SelectCardState createState() => _SelectCardState(choice);
}

class _SelectCardState extends State<SelectCard> {
  final Choice choice;

  _SelectCardState(this.choice);

  @override
  Widget build(BuildContext context) {
    clearListFirst();
    makeProductList();
    return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              CatResultPage(name: choice.name)),
        ),
        child: Card(
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 19.0 / 13.0,
                      child: Image.network(
                        choice.image.toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                        child: Text(choice.name),
                      ),
                    ),
                  ]),
            ))
    );
  }
}