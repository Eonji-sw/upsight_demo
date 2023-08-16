/*
홈 화면
bottomTabBar : o
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/size.dart';
import '../providers/question_firestore.dart';
import '../widgets/gradient_base.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // firebase 객체 생성
  QuestionFirebase questionFirebase = QuestionFirebase();

  late QuerySnapshot openSnapshot;
  late Future<QuerySnapshot> hotOpenFuture;

  @override
  void initState() {
    super.initState();

    setState(() {
      hotOpenFuture = fetchHotOpen();
    });
  }

  // 자유게시판 인기 글 반환하는 함수
  Future<QuerySnapshot> fetchHotOpen() async {
    // firebase 객체 초기화
    questionFirebase.initDb();
    openSnapshot = await questionFirebase.questionReference.orderBy('views_count', descending: true).limit(1).get();
    return openSnapshot;
  }

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
                child: Column(
                  children: [
                    Container(
                      width: 117,
                      height: 53,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    Text('UPSIGHT',
                      style: TextStyle(
                        color: KEY_BLUE,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
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
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    height: 133.55,
                    decoration: buildShapeDecoration(),
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
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: FutureBuilder<QuerySnapshot>(
                    future: hotOpenFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // 로딩 중인 경우 로딩 표시
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No data available'); // 데이터가 없는 경우 표시
                      } else {
                        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                        return Container(
                          width: double.infinity,
                          height: 257.19,
                          decoration: buildShapeDecoration(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  data['title'],
                                  style: TextStyle(
                                    color: BLACK,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2,),
                                Text(
                                  data['content'],
                                  style: TextStyle(
                                    color: BLACK,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    Icon(Icons.account_circle_outlined, color: ICON_GREY,),
                                    SizedBox(width: 5,),
                                    Text(
                                      data['author'],
                                      style: TextStyle(
                                        color: TEXT_GREY,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
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
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    height: 257.19,
                    decoration: buildShapeDecoration(),
                  ),
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