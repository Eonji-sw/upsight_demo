/*import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:board_project/screens/login_secure.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';
import 'package:board_project/providers/user_firestore.dart';
import 'package:board_project/providers/question_firestorage.dart';

import '../providers/question_firestore.dart';

class APITestScreen extends StatefulWidget {
  @override
  _APITestScreenState createState() => _APITestScreenState();
}

class _APITestScreenState extends State<APITestScreen> {
  File? imageFile;
  UserFirebase userFirebase = UserFirebase();
  QuestionFirebase questionFirebase = QuestionFirebase();
  FileStorage fileStorage = FileStorage();
  late String? userName;

  // 게시물의 사진 초기화
  final List<File> _images = [];
  final picker = ImagePicker();

  Future<void> fetchUser() async {
    UserFirebase().getUserById(FirebaseAuthProvider().authClient.currentUser!.uid)
        .then((result) {
      var userData = result as Map<String, dynamic>;
      if (userData != null) {

        setState(() {
          userName = userData["name"];
        });
        logger.d(userName);
        //return user;
      }else{
        logger.e("fetchUser error: 유저 정보를 가져오지 못하였습니다.");
        //return null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      // firebase 객체 초기화
      questionFirebase.initDb();
      userFirebase.initDb();
    });
    fetchUser();
    //init();
  }


  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageFile == null
                ? Text('No Image Selected')
                : Image.file(imageFile!), //load image if uploaded
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: ()=>getImageFromURL(context), //임시로 가져옴
              child: Text('Select Image'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImageFromURL(BuildContext context) async {
    try {
      var url = await fileStorage.getFile(userName!, "test_2023-08-11 08:53:18.087758Z");
      if (url != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('Image from URL')),
              body: Center(
                child: Image.network(url as String),
              ),
            ),
          ),
        );
      } else {
        // Handle the case when the URL is null or image not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image not found.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle any errors that may occur
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}*/
