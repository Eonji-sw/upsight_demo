/*
홈 화면
 */

import 'package:flutter/material.dart';

import '../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16,),
          Container(
            width: 85,
            height: 21,
            child: Image.asset('assets/images/logo.png'),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, top: 16),
            child: Text('캘린더',
              style: TextStyle(
                color: BLACK,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Container(
              width: 322,
              height: 61,
              decoration: ShapeDecoration(
                color: WHITE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: [
                  BoxShadow(
                    color: BOX_SHADOW_COLOR,
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, top: 16),
            child: Text('공간 이미지',
              style: TextStyle(
                color: BLACK,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Container(
              width: 322,
              height: 133.55,
              decoration: ShapeDecoration(
                color: WHITE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: [
                  BoxShadow(
                    color: BOX_SHADOW_COLOR,
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, top: 16),
            child: Text('하자 보수 게시판 인기 글',
              style: TextStyle(
                color: BLACK,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Container(
              width: 322,
              height: 257.19,
              decoration: ShapeDecoration(
                color: WHITE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: [
                  BoxShadow(
                    color: BOX_SHADOW_COLOR,
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}