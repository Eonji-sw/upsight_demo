import 'package:flutter/material.dart';

import '../constants/colors.dart';

class ButtonYes extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;

  const ButtonYes({Key? key, required this.name, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(114, 44)), // 버튼 크기 지정
          backgroundColor: MaterialStateProperty.all(KEY_BLUE), // 배경색 변경
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), // 모서리 둥글게 처리
        ),
        child: Text(name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: WHITE,
            fontSize: 18,
            fontFamily: 'Pretendard Variable',
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: onPressed
    );
  }
}