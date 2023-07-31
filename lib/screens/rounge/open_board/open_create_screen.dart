/*
게시글(question) 생성하는 page
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:intl/intl.dart';
import 'package:board_project/providers/question_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:board_project/providers/user_firestore.dart';

import '../../../constants/colors.dart';
import '../../../constants/size.dart';
import '../../../router.dart';
import '../../../widgets/appbar_back.dart';
import '../../../widgets/button_no.dart';
import '../../../widgets/button_yes.dart';
import '../../../widgets/dialog_base.dart';
import '../../../widgets/divider_base.dart';
import '../../../widgets/textform_base.dart';


class OpenCreateScreen extends StatefulWidget {
  _OpenCreateScreenState createState() => _OpenCreateScreenState();
}

class _OpenCreateScreenState extends State<OpenCreateScreen> {
  // firebase 객체 생성
  QuestionFirebase questionFirebase = QuestionFirebase();
  UserFirebase userFirebase = UserFirebase();

  // 새로 생성하는 question model의 각 필드 초기화
  String title = '';
  String content = '';
  String author = '';
  String create_date = '';
  String modify_date = 'Null';
  String category = '';
  int views_count = COMMON_INIT_COUNT;
  bool isLikeClicked = false;
  int answerCount = COMMON_INIT_COUNT;

  // 게시글(question) 하나를 눌렀을 때 detail screen에 넘겨줄 해당 게시글의 documentId, documentSnapshot
  late String questionId;
  late DocumentSnapshot questionDoc;

  // 현재 로그인한 사용자 name
  late String user;

  // 게시물의 사진 초기화
  final List<File> _images = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    setState(() {
      // firebase 객체 초기화
      questionFirebase.initDb();
      userFirebase.initDb();
    });
    // user_id 값을 가져와서 user 변수에 할당
    fetchUser();
  }

  // 사용자 데이터를 가져와서 user 변수에 할당하는 함수
  Future<void> fetchUser() async {
    final userSnapshot = await userFirebase.userReference.get();

    if (userSnapshot.docs.isNotEmpty) {
      final document = userSnapshot.docs.first;
      setState(() {
        user = (document.data() as Map<String, dynamic>)['user_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: AppbarBack(title: '게시글 작성'),
        ),
      // body
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              DividerBase(),
              // 카테고리 입력
              TextFormField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '카테고리를 입력해주세요.',
                    prefixText: '#',
                    hintStyle: TextStyle(
                      color: TEXT_GREY,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    )
                ),
                // category 값이 작성되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    category = value;
                  });
                },
              ),
              DividerBase(),
              // 제목 입력
              TextformBase(text: '제목을 입력해주세요.', maxLine: 1, maxLength: MAX_TITLE_LENGTH,
                // title 값이 작성되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
              DividerBase(),
              // 내용 입력
              TextformBase(text: '내용을 입력해주세요.', maxLine: MAX_LINE, maxLength: MAX_CONTNET_LENGTH,
                // content 값이 작성되었는지 확인하여 입력 받은 데이터 저장
                onChanged: (value) {
                  setState(() {
                    content = value;
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
              // 게시글 작성 완료 버튼
              GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: Text('작성 완료',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: (title.isNotEmpty && content.isNotEmpty && category.isNotEmpty) ? KEY_BLUE : TEXT_GREY,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                onTap: () {
                  (title.isNotEmpty && content.isNotEmpty && category.isNotEmpty) ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DialogBase(
                        title: '게시글 작성을 완료하시겠습니까?',
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
                              await createQuestion(context);
                            },
                          ),
                        ],
                      );
                    },
                  ) : Null;
                },
              ),
            ],
          ),
        ),
      )
    );
  }

  // 질문 생성 함수
  Future<void> createQuestion(BuildContext context) async {
    // 필수 필드가 작성되었는지 확인
    if (title.isNotEmpty && content.isNotEmpty && category.isNotEmpty) {
      // 입력받은 데이터로 새로운 question 데이터 생성하여 DB에 생성
      Question newQuestion = Question(
        title: title,
        content: content,
        author: user,
        create_date: DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
        modify_date: modify_date,
        category: category,
        views_count: views_count,
        isLikeClicked: isLikeClicked,
        answerCount: answerCount,
      );
      questionFirebase.addQuestion(newQuestion);
      Navigator.pushNamed(context, boardRoute);
      // 이미지 storage에 업로드
      // for (int i = 0; i < _images.length; i++) {
      //   FirebaseStorage.instance.ref("question/test_${i}").putFile(_images[i]);
      // }
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