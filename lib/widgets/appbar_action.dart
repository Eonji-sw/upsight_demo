import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AppbarAction extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const AppbarAction({Key? key, required this.title, required this.actions}) : super(key: key);

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
      // 더보기
      actions: actions
    );
  }
}