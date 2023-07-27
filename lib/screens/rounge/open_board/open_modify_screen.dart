/*
게시글(question) 수정하는 page
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:board_project/providers/question_firestore.dart';

import '../../../constants/colors.dart';
import '../../../constants/size.dart';
import '../../../widgets/appbar_base.dart';
import '../../../widgets/divider_base.dart';

class OpenModifyScreen extends StatefulWidget {
  // detail_screen에서 전달받는 해당 question 데이터
  final Question data;

  OpenModifyScreen({required this.data});

  _OpenModifyScreenState createState() => _OpenModifyScreenState();
}

class _OpenModifyScreenState extends State<OpenModifyScreen> {
  QuestionFirebase questionFirebase = QuestionFirebase();

  // 전달받은 question 데이터 저장할 변수
  late Question questionData;

  // 전달받은 question 데이터의 DocumentSnapshot id 저장할 변수
  late String document;

  _OpenModifyScreenState() {
    questionFirebase.initDb();
  }

  final List<File> _images = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 전달받은 question 데이터 저장
    questionData = widget.data;
    // 해당 question 데이터의 snapshot 저장
    fetchQuestionData();
  }

  // 해당 question 데이터의 snapshot 저장하는 함수
  void fetchQuestionData() async {
    // 수정할 question 데이터의 DocumentSnapshot() 찾아서 저장
    QuerySnapshot snapshot = await questionFirebase.questionReference
        .where('title', isEqualTo: questionData.title)
        .where('content', isEqualTo: questionData.content)
        .where('author', isEqualTo: questionData.author)
        .where('create_date', isEqualTo: questionData.create_date)
        .get();

    if (snapshot.docs.isNotEmpty) {
      document = snapshot.docs.first.id;
      setState(() {});
    }
  }

  // 위젯을 만들고 화면에 보여주는 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar 구현 코드
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppbarBase(title: '게시글 수정', back: true,),
      ),
      // appBar 아래 UI 구현 코드
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              DividerBase(),
              TextFormField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: questionData.category,
                    prefixText: '#',
                    hintStyle: TextStyle(
                      color: TEXT_GREY,
                      fontSize: 16,
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w300,
                    )
                ),
                // category 값이 변경되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    questionData.category = value;
                  });
                },
              ),
              DividerBase(),
              TextFormField(
                maxLength: MAX_TITLE_LENGTH,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: questionData.title,
                    hintStyle: TextStyle(
                      color: TEXT_GREY,
                      fontSize: 16,
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w300,
                    )
                ),
                // title 값이 변경되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    questionData.title = value;
                  });
                },
              ),
              DividerBase(),
              TextFormField(
                maxLines: MAX_LINE,
                maxLength: MAX_CONTNET_LENGTH,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: questionData.content,
                    hintStyle: TextStyle(
                      color: TEXT_GREY,
                      fontSize: 16,
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w300,
                    )
                ),
                // content 값이 변경되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    questionData.content = value;
                  });
                },
              ),
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
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                onTap: () async {
                  await modifyQuestion(context);
                },
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> modifyQuestion(BuildContext context) async {
    // 모든 필드가 작성되었는지 확인
    if (questionData.title.isNotEmpty && questionData.content.isNotEmpty && questionData.category.isNotEmpty) {
      // 입력받은 데이터로 새로운 question 데이터 생성하여 DB에 업데이트
      Question newQuestion = Question(
        title: questionData.title,
        content: questionData.content,
        author: questionData.author,
        create_date: questionData.create_date,
        modify_date:
        DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
        category: questionData.category,
        views_count: questionData.views_count,
        isLikeClicked: questionData.isLikeClicked,
        reference: questionData.reference,
        answerCount: questionData.answerCount,
      );
      await questionFirebase.updateQuestion(newQuestion);
      await questionFirebase.questionReference.doc(document).update({
        'title': questionData.title,
        'content': questionData.content,
        'author': questionData.author,
        'create_date': questionData.create_date,
        'modify_date':
        DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
        'category': questionData.category,
        'views_count': questionData.views_count,
        'isLikeClicked': questionData.isLikeClicked,
      });
      // 수정된 question 데이터를 가지고 게시물 list screen으로 전환
      Navigator.pushNamed(context, '/test', arguments: newQuestion);
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
