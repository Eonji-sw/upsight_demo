/*
홈 화면
bottomTabBar : o
 */

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../widgets/gradient_base.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로고
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 117,
                  height: 53,
                  child: Image.asset('assets/images/logo.png'),
                ),
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
      )
    );
  }
}