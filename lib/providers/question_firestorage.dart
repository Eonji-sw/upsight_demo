import 'package:board_project/screens/login_secure.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:board_project/providers/user_firestore.dart';

import 'package:intl/intl.dart';

import '../constants/size.dart';
import '../models/user.dart';


class FileStorage extends GetxController{
  late FirebaseStorage storage;
  late Reference storageRef;
  late Map<String, dynamic> userData;

  FileStorage(){
    storage= FirebaseStorage.instance;

  }


  Future<String?> uploadFile(File uploadFile, String uploadPath) async {
    try{
      storageRef = storage.ref(uploadPath);
      await storageRef.putFile(uploadFile);
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    }on FirebaseException catch (e){
      logger.e("파일 업로드 에러", error: e);
      return null;
    }
  }

  Future<String?> getFile(String userName, String downloadPath) async {
    try {
      // Get a reference to the file
      storageRef = storage.ref("question");
      Reference? imagesRef = storageRef.child(userName);
      // Check if the file exists
      if (imagesRef != null) {
        Reference imageRef = imagesRef.child(downloadPath);
        var url = await imageRef.getDownloadURL();
        logger.d("url: $url");
        return url;
      } else {
        logger.e('File no'
            't found.');
      }
    } catch (e) {
      logger.e('Error: $e');
    }
  }




}