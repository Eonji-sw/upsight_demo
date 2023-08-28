import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/space.dart';
import 'dart:async';

import '../screens/login_secure.dart';

class SpaceFirebase {
  late CollectionReference spaceReference;
  late Stream<QuerySnapshot> spaceStream;

  Future initDb() async {
    spaceReference = FirebaseFirestore.instance.collection('space');
    spaceStream = spaceReference.snapshots();
  }

  List<Space> getSpaces(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((DocumentSnapshot document) {
      return Space.fromSnapshot(document);
    }).toList();
  }

  Future addSpace(Space space) async {
    spaceReference.add(space.toMap());
  }

  Future updateSpace(Space space) async {
    space.reference?.update(space.toMap());
  }

  Future deleteSpace(Space space) async {
    space.reference?.delete();
  }
  Future <List?> getFile(Space space) async{
    //firestore에서 url 가져오는 함수
    try {
      return space.img_url;
    } catch (e) {
      logger.e('Error: $e');
    }
    return null;
  }

}
