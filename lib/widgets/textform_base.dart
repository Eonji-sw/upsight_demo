import 'package:flutter/material.dart';

import '../constants/colors.dart';

class TextformBase extends StatelessWidget {
  final String text;
  final int maxLine;
  final int maxLength;
  final ValueChanged<String>? onChanged;
  const TextformBase({Key? key, required this.text, required this.maxLine, required this.maxLength, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLine,
      maxLength: maxLength,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: text,
          hintStyle: TextStyle(
            color: TEXT_GREY,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          )
      ),
      // content 값이 작성되었는지 확인하여 입력 받은 데이터 저장
      onChanged: onChanged,
    );
  }
}