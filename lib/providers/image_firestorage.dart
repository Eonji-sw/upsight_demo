import 'package:board_project/screens/login_secure.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';


class FileStorage extends GetxController{
  late FirebaseStorage storage;
  late Reference? storageRef;

  FileStorage(){
    storage= FirebaseStorage.instance;
  }

  Future<String?> uploadStorage(File uploadFile, String uploadPath) async {
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
}