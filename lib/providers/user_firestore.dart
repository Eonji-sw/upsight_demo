import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/user.dart';
import 'dart:async';

class UserFirebase {
  late CollectionReference userReference;
  late Stream<QuerySnapshot> userStream;

  Future initDb() async {
    userReference = FirebaseFirestore.instance.collection('user');
    userStream = userReference.snapshots();
  }

  List<User> getUser(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((DocumentSnapshot document) {
      return User.fromSnapshot(document);
    }).toList();
  }

}