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

  Future<void>getFile(String downloadPath) async{
    try{
      storageRef = storage.ref(downloadPath);

    }catch(e){}
  }




}