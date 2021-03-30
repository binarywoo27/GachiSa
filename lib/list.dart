import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

final List<Record> productitem = [];

void clearListFirst() {
  productitem.clear();
}

void makeProductList() {
  final Query products = FirebaseFirestore.instance.collection('products');
  products.getDocuments().then((snapshot) {
    snapshot.docs.forEach((doc){
      print("doc.data is ===> " + doc.data()['id'].toString());
      // ProductItem product = new ProductItem();
      // product.title = doc.data()['name'].toString();
      // product.category = doc.data()['category'].toString();
      final product = Record.fromSnapshot(doc);
      // product.
      productitem.add(product);
    });
  });
}

List<Record> loadProductItem() {
  return productitem;
}










// class ProductItem{
//   String title;
//   String category;
//   ProductItem({
//     this.title,
//     this.category,
//   });
// }