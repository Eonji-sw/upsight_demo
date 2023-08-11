/*
홈 화면
bottomTabBar : o
 */

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/size.dart';
import '../widgets/gradient_base.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final double statusBarSize = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: statusBarSize, bottom: BOTTOM_TAB),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 로고
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 117,
                  height: 53,
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
              // 정보 배너
              GradientBase(),
              // 내 스케줄
              Padding(
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 7),
                child: Text('내 스케줄',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: BLACK,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 322,
                  height: 133.55,
                  decoration: buildShapeDecoration(),
                ),
              ),
              // 자유게시판 인기 글
              Padding(
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 7),
                child: Text('자유게시판 인기 글',
                  style: TextStyle(
                    color: BLACK,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 322,
                  height: 257.19,
                  decoration: buildShapeDecoration(),
                ),
              ),
              // 질문하기 인기 글
              Padding(
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 7),
                child: Text('질문하기 인기 글',
                  style: TextStyle(
                    color: BLACK,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 322,
                  height: 257.19,
                  decoration: buildShapeDecoration(),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  // shapeDecoration 반환하는 함수
  ShapeDecoration buildShapeDecoration() {
    return ShapeDecoration(
      color: WHITE,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ROUND_BORDER),
      ),
      shadows: [
        BoxShadow(
          color: BOX_SHADOW_COLOR,
          blurRadius: 4,
          offset: Offset(0, 0),
          spreadRadius: 2,
        )
      ],
    );
  }
}