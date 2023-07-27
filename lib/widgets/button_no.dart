import 'package:flutter/material.dart';

import '../constants/colors.dart';

class ButtonNo extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;

  const ButtonNo({Key? key, required this.name, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size(114, 44)), // 버튼 크기 지정
        backgroundColor: MaterialStateProperty.all(WHITE), // 배경색 변경
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
                side: BorderSide(width: 1, color: L_GREY,),
                borderRadius: BorderRadius.circular(4)
            )
        ), // 모서리 둥글게 처리
      ),
      child: Text(name,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: TEXT_GREY,
          fontSize: 18,
          fontFamily: 'Pretendard Variable',
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
    );
  }
}