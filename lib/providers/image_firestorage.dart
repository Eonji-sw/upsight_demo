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
import 'package:board_project/providers/question_firestore.dart';

class FileStorage extends GetxController{
  late FirebaseStorage storage;
  late Reference? storageRef;
  late Map<String, dynamic> userData;

  FileStorage(){
    storage= FirebaseStorage.instance;
  }


  Future<String?> uploadFile(File uploadFile, String uploadPath) async {
    try{
      storageRef = storage.ref(uploadPath);
      String? url;
      await storageRef?.putFile(uploadFile).whenComplete(() async {
        await storageRef?.getDownloadURL().then((value){
          logger.d("uploadFile logger, return value: $value");
          url = value;
        });
      });
      return url;
    }on FirebaseException catch (e){
      logger.e("파일 업로드 에러", error: e);
      return null;
    }
  }

  List? getFile(Question questionData){
    //firestore에서 url 가져오는 함수
    try {
      logger.d("getFile values: ${questionData.img_url}");
      return questionData.img_url;
      } catch (e) {
      logger.e('Error: $e');
    }
    return null;
  }


}