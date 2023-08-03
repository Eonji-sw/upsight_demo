import 'package:flutter/material.dart';

class ResetPasswordFieldModel extends ChangeNotifier {
  String email = "";

  //사용자 이름도 향후 추가

  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }
}
