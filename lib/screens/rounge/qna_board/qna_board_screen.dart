/*
Q&A 전체 게시글 보여주는 list page : 무한 스크롤 페이지네이션, 정렬 기능 구현
 */

import 'package:board_project/providers/question_firestore.dart';
import 'package:board_project/providers/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:board_project/screens/rounge/open_board/open_create_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:board_project/models/user.dart';
import '../../../constants/colors.dart';
import '../../../constants/size.dart';
import '../../../widgets/appbar_base.dart';
import '../open_board/open_board_screen.dart';

class QnaBoardScreen extends StatefulWidget {
  @override
  _QnaBoardScreenState createState() => _QnaBoardScreenState();
}

class _QnaBoardScreenState extends State<QnaBoardScreen> {
  @override
  void initState() {
    super.initState();
  }

  // 위젯을 만들고 화면에 보여주는 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: AppbarBase(title: '라운지'),
        ),
      body: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OpenBoardScreen()),
                          );
                        },
                        child: Text('자유게시판',
                          style: TextStyle(
                            color: TEXT_GREY,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: SizedBox(
                            height: 2,
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: WHITE
                              ),
                            ),
                          )
                      )
                    ]
                ),
              ),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => QnaBoardScreen()),
                            );
                          },
                          child: Text('질문하기',
                            style: TextStyle(
                              color: KEY_BLUE,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: SizedBox(
                              height: 2,
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: KEY_BLUE
                                ),
                              ),
                            )
                        )
                      ]
                  )
              )
            ],
          ),
        ],
      ),
    );
  }
}