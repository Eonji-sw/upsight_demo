import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/user.dart';
import 'dart:async';

import '../screens/login_secure.dart';

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

  ///Id값을 입력하여  유저 정보를 받아오는 구문
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      // Get the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a query to find the document with the matching email
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('user')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      // Check if the query returned any results
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot=querySnapshot.docs.first;
        Map<String, dynamic>? userData = documentSnapshot.data();
        return userData;
      }
    } catch (e) {
      // Handle any errors that may occur during the query
      print('없어: $e');
      return null;
    }
    return null;
  }
  ///회원가입 후 db create
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      // Get the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get the required fields from the input map
      String userId = userData['user_id'] ?? 'null'; // Set to empty string if null
      String userEmail = userData['user_email'] ?? 'null'; // Set to empty string if null
      String userName = userData['name'] ?? 'null'; // Set to empty string if null

      // Create a new document in the user collection with the provided userId
      await firestore.collection('user').doc().set({
        'user_id': userId,
        'user_email': userEmail,
        'name': userName,
        // You can add other optional fields here if needed
      });

      logger.d('User created successfully.');
    } catch (e) {
      // Handle any errors that may occur during the creation
      logger.d('Error: $e');
    }
  }



}