import 'package:board_project/constants/colors.dart';
import 'package:flutter/material.dart';

class GradientBase extends StatelessWidget {
  const GradientBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFFf7e2f2), Color(0xFFe2f2f7)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('정보 배너 글 제목 입력',
              style: TextStyle(
                color: SUB_BLUE,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text('이 곳에 내용 최대 1열까지만 작성하도록 한다.',
              style: TextStyle(
                color: ICON_GREY,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
    );
  }
}