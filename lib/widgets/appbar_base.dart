import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AppbarBase extends StatelessWidget {
  final String title;
  final bool back;
  const AppbarBase({Key? key, required this.title, required this.back}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: back,
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
      // 뒤로가기 버튼
      // leading: IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     color: BLACK,
      //     icon: Icon(Icons.arrow_back_ios_new)),
    );
  }
}