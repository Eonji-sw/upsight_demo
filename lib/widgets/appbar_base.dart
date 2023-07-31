import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AppbarBase extends StatelessWidget {
  final String title;
  const AppbarBase({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
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
    );
  }
}