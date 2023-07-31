import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AppbarBack extends StatelessWidget {
  final String title;

  const AppbarBack({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: WHITE,
      centerTitle: true,
      // 제목
      title: Text(title,
        style: TextStyle(
          color: BLACK,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      // 뒤로가기
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: BLACK,
          icon: Icon(Icons.arrow_back_ios_new)),
    );
  }
}