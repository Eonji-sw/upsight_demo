/*
게시글(question) 수정하는 page
 */

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
import '../../../router.dart';
import '../../../widgets/appbar_back.dart';
import '../../../widgets/button_no.dart';
import '../../../widgets/button_yes.dart';
import '../../../widgets/dialog_base.dart';
import '../../../widgets/divider_base.dart';
import '../../../widgets/textform_base.dart';


class OpenModifyScreen extends StatefulWidget {
  // detail_screen에서 전달받는 해당 question, questionId 데이터
  final Question data;
  final String dataId;

  OpenModifyScreen({required this.data, required this.dataId});
  _OpenModifyScreenState createState() => _OpenModifyScreenState();
}

class _OpenModifyScreenState extends State<OpenModifyScreen> {
  // firebase 객체 생성
  QuestionFirebase questionFirebase = QuestionFirebase();

  String boardCategory = '';
  int lastBoardIndex = COMMON_INIT_COUNT;
  int lastCategoryIndex = COMMON_INIT_COUNT;

  // 전달받은 question, qeustionId 데이터 저장할 변수
  late Question questionData;
  late String questionId;

  // 게시물의 사진 초기화
  final List<File> _images = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 전달받은 question 데이터 저장
    questionData = widget.data;
    questionId = widget.dataId;

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
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppbarBack(title: '게시글 수정'),
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
                    questionData.title = value;
                  });
                },
              ),
              DividerBase(),
              // 내용 입력
              TextformBase(text: questionData.content, maxLine: MAX_LINE, maxLength: MAX_CONTNET_LENGTH,
                // content 값이 변경되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    questionData.content = value;
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
                        color: (questionData.title.isNotEmpty && questionData.content.isNotEmpty && questionData.category.isNotEmpty) ? KEY_BLUE : TEXT_GREY,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                onTap: () {
                  showDialog(
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
                  );
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
    if (questionData.title.isNotEmpty && questionData.content.isNotEmpty && questionData.category.isNotEmpty) {
      // 입력받은 데이터로 새로운 question 데이터 생성하여 DB에 업데이트
      await questionFirebase.questionReference.doc(questionId).update({
        'title': questionData.title,
        'content': questionData.content,
        'author': questionData.author,
        'create_date': questionData.create_date,
        'modify_date': DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
        'category': questionData.category,
        'views_count': questionData.views_count,
        'isLikeClicked': questionData.isLikeClicked,
      });
      // 수정된 question 데이터를 가지고 게시물 list screen으로 전환
      Navigator.pushNamed(context, boardRoute, arguments: questionFirebase.questionReference.doc(questionId).get());
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

  // 이미지 삭제하는 함수
  delImage(File image) {
    _images.remove(image);
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
                  delImage(image);
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
