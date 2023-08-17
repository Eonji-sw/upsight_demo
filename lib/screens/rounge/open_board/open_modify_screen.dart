/*
게시글(question) 수정하는 page
cupertinoPicker 기능 구현
bottomTabBar : x
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:board_project/providers/question_firestore.dart';

import '../../../constants/colors.dart';
import '../../../constants/list.dart';
import '../../../constants/size.dart';
import '../../../widgets/appbar_back.dart';
import '../../../widgets/button_no.dart';
import '../../../widgets/button_yes.dart';
import '../../../widgets/dialog_base.dart';
import '../../../widgets/divider_base.dart';
import '../../../widgets/textform_base.dart';
import 'open_detail_screen.dart';


class OpenModifyScreen extends StatefulWidget {
  // detail_screen에서 전달받는 해당 question, questionId, questionDoc 데이터
  final Question data;
  final String dataId;
  final DocumentSnapshot dataDoc;

  OpenModifyScreen({required this.data, required this.dataId, required this.dataDoc});
  _OpenModifyScreenState createState() => _OpenModifyScreenState();
}

class _OpenModifyScreenState extends State<OpenModifyScreen> {
  // firebase 객체 생성
  QuestionFirebase questionFirebase = QuestionFirebase();

  String boardCategory = '';
  int lastBoardIndex = COMMON_INIT_COUNT;
  int lastCategoryIndex = COMMON_INIT_COUNT;

  // 전달받은 question, questionId, questionDoc 데이터 저장할 변수
  late Question questionData;
  late String questionId;
  late DocumentSnapshot questionDoc;

  // 수정한 게시물 데이터
  String modifyTitle = '';
  String modifyContent = '';

  // 게시물의 사진 초기화
  final List<File> _images = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 전달받은 question, questionId, questionDoc 데이터 저장
    questionData = widget.data;
    questionId = widget.dataId;
    questionDoc = widget.dataDoc;

    setState(() {
      // firebase 객체 초기화
      questionFirebase.initDb();
      boardCategory = '자유게시판';
      lastBoardIndex = BoardList.indexWhere((e) => e == boardCategory);
      lastCategoryIndex = BoardFilterList.indexWhere((e) => e == questionData.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar
      // appBar: const PreferredSize(
      //   preferredSize: Size.fromHeight(65),
      //   child: AppbarBack(title: '게시글 수정'),
      // ),
      appBar: AppBar(
        backgroundColor: WHITE,
        centerTitle: true,
        // 제목
        title: Text('게시글 수정',
          style: TextStyle(
            color: BLACK,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        // 뒤로가기
        leading: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DialogBase(
                      title: '이 페이지를 나가면 게시글 수정사항이 저장되지 않습니다. 나가시겠습니까?',
                      actions: [
                        ButtonNo(
                          name: '아니오',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ButtonYes(
                          name: '예',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => OpenDetailScreen(data: questionData, dataId: questionId, dataDoc: questionDoc),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
              );
            },
            color: BLACK,
            icon: Icon(Icons.arrow_back_ios_new)),
      ),
      // body
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              DividerBase(),
              // 게시판 & 카테고리 선택
              CupertinoButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 32,
                                scrollController: FixedExtentScrollController(initialItem: lastBoardIndex),
                                onSelectedItemChanged: (int index) {
                                  Text(boardCategory,
                                    style: TextStyle(
                                      color: BLACK,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  );
                                  setState(() {
                                    lastBoardIndex = index;
                                    boardCategory = BoardList[index];
                                  },
                                  );
                                },
                                children: List<Widget>.generate(
                                  BoardList.length,
                                      (int index) {
                                    return Center(
                                      child: Text(BoardList[index]),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 32,
                                scrollController: FixedExtentScrollController(initialItem: lastCategoryIndex),
                                onSelectedItemChanged: (int index) {
                                  Text(questionData.category,
                                    style: TextStyle(
                                      color: BLACK,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  );
                                  setState(() {
                                    lastCategoryIndex = index;
                                    questionData.category = BoardFilterList[index];
                                  },
                                  );
                                },
                                children: List<Widget>.generate(
                                  BoardFilterList.length,
                                      (int index) {
                                    return Center(
                                      child: Text(BoardFilterList[index]),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(boardCategory,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: BLACK,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 28,
                      decoration: BoxDecoration(
                        color: L_GREY,
                      ),
                      alignment: Alignment.center,
                    ),
                    Text(questionData.category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: BLACK,
                      ),
                    ),
                  ],
                ),
              ),
              DividerBase(),
              // 제목 입력
              TextformBase(text: questionData.title, maxLine: 1, maxLength: MAX_TITLE_LENGTH,
                // title 값이 변경되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    modifyTitle = value;
                  });
                },
              ),
              DividerBase(),
              // 내용 입력
              TextformBase(text: questionData.content, maxLine: MAX_LINE, maxLength: MAX_CONTNET_LENGTH,
                // content 값이 변경되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    modifyContent = value;
                  });
                },
              ),
              // 이미지 입력
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add_photo_alternate_outlined),
                    onPressed: () {
                      getImage();
                    },
                  ),
                ],
              ),
              showImage(),
              DividerBase(),
              // 게시글 수정 완료 버튼
              GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      '수정 완료',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: (modifyTitle.isNotEmpty && modifyContent.isNotEmpty && boardCategory.isNotEmpty) ? KEY_BLUE : TEXT_GREY,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                onTap: () {
                  (modifyTitle.isNotEmpty && modifyContent.isNotEmpty && questionData.category.isNotEmpty) ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DialogBase(
                        title: '게시글 수정을 완료하시겠습니까?',
                        actions: [
                          ButtonNo(
                            name: '아니오',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ButtonYes(
                            name: '예',
                            onPressed: () async {
                              await modifyQuestion(context);
                            },
                          ),
                        ],
                      );
                    },
                  ) : Null;
                }
              ),
            ],
          ),
        ),
      )
    );
  }

  // 질문 수정 함수
  Future<void> modifyQuestion(BuildContext context) async {
    // 모든 필드가 작성되었는지 확인
    if (modifyTitle.isNotEmpty && modifyContent.isNotEmpty && questionData.category != '글 주제 선택') {
      // 입력받은 데이터로 새로운 question 데이터 생성하여 DB에 업데이트
      Question modifyQuestion = Question(
        title: modifyTitle,
        content: modifyContent,
        author: questionData.author,
        create_date: questionData.create_date,
        modify_date: DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
        category: questionData.category,
        views_count: questionData.views_count,
        isLikeClicked: questionData.isLikeClicked,
        answerCount: questionData.answerCount,
        img_url: questionData.img_url,
      );
      await questionFirebase.questionReference.doc(questionId).update(modifyQuestion.toMap());
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => OpenDetailScreen(data: modifyQuestion, dataId: questionId, dataDoc: questionDoc),
        ),
      );
    }
  }

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져옴
  getImage() async {
    final List<XFile> images = await picker.pickMultiImage();
    if (images != null) {
      images.forEach((e) {
        _images.add(File(e.path));
      });

      setState(() {});
    }
  }

  // 이미지를 보여주는 위젯
  Widget showImage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: 2.5,
        children: _images.map((e) => _gridImage(e)).toList(),
      ),
    );
  }

  // 이미지 UI 위젯
  Widget _gridImage(File image) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _images.remove(image);
                });
              },
              child: Container(
                width: 20,
                height: 20,
                child: Icon(
                  Icons.cancel,
                  size: 15,
                ),
              ),
            )
        )
      ],
    );
  }
}
