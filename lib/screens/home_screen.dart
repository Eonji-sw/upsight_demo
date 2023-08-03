/*
홈 화면
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
            Padding(
              padding: EdgeInsets.only(top: 30, bottom: 10),
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
            Padding(
              padding: EdgeInsets.only(left: 20, top: 16, bottom: 7),
              child: Text('하자 보수 게시판 인기 글',
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
            )
          ],
        ),
      )
    );
  }
}