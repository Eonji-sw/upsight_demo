/*
게시글(question) 생성하는 page
cupertinoPicker 기능 구현
bottomTabBar : x -> 어차피 floatingActionButton을 통해 들어가는 페이지라 별도 처리가 없어도 bottomTabBar가 뜨지 않음
 */

import 'package:board_project/screens/rounge/open_board/open_board_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:intl/intl.dart';
import 'package:board_project/providers/question_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:board_project/providers/user_firestore.dart';
import 'package:board_project/providers/question_firestorage.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/list.dart';
import '../../../constants/size.dart';
import '../../../widgets/appbar_back.dart';
import '../../../widgets/button_no.dart';
import '../../../widgets/button_yes.dart';
import '../../../widgets/dialog_base.dart';
import '../../../widgets/divider_base.dart';
import '../../../widgets/textform_base.dart';
import 'package:board_project/screens/login_secure.dart';
import 'package:get/get.dart';
import 'package:board_project/providers/user_firestore.dart';

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
  List <String?> img_url =[];

  String boardCategory = '';
  int lastBoardIndex = COMMON_INIT_COUNT;
  int lastCategoryIndex = COMMON_INIT_COUNT;

  // 게시글(question) 하나를 눌렀을 때 detail screen에 넘겨줄 해당 게시글의 documentId, questionDoc, documentSnapshot
  late String questionId;
  late DocumentSnapshot questionDoc;
  late QuerySnapshot? questionSnapshot;

  // 현재 로그인한 사용자 name
  late String? userName;

  // 게시물의 사진 초기화
  final List<File> _images = [];
  final picker = ImagePicker();

  @override
  void initState(){
    super.initState();

    // firebase 객체 초기화
    questionFirebase.initDb();
    userFirebase.initDb();
    boardCategory = '자유게시판';
    category = '글 주제 선택';

    // user_id 값을 가져와서 user 변수에 할당
/*    fetchUser()
        .then((userName) {this.userName =userName;});*/
    fetchUser();
  }

  // 사용자 데이터를 가져와서 user 변수에 할당하는 함수
    Future<void> fetchUser() async {
          UserFirebase().getUserById(FirebaseAuthProvider().authClient.currentUser!.uid)
        .then((result) {
            var userData = result as Map<String, dynamic>;
            if (userData != null) {
                userName = userData["name"];
              logger.d(userName);
              //return user;
            }else{
              logger.e("fetchUser error: 유저 정보를 가져오지 못하였습니다.");
            }
          });
  }

  @override
  Widget build(BuildContext context) {
    logger.d("open create state build call");
    return Scaffold(
      // appBar
      //   appBar: const PreferredSize(
      //     preferredSize: Size.fromHeight(65),
      //     child: AppbarBack(title: '게시글 작성'),
      //   ),
      appBar: AppBar(
        backgroundColor: WHITE,
        centerTitle: true,
        // 제목
        title: Text('게시글 작성',
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
                      title: '이 페이지를 나가면 작성하던 게시글 내용이 삭제됩니다. 나가시겠습니까?',
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
                                builder: (BuildContext context) => OpenBoardScreen(),
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
                                  Text('글 주제 선택',
                                    style: TextStyle(
                                      color: BLACK,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  );
                                  setState(() {
                                    lastCategoryIndex = index;
                                    category = BoardFilterList[index];
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
                    Text(category,
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
                        color: (title.isNotEmpty && content.isNotEmpty && category != '글 주제 선택') ? KEY_BLUE : TEXT_GREY,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                onTap: () {
                  (title.isNotEmpty && content.isNotEmpty && category != '글 주제 선택') ? showDialog(
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
    FileStorage fileStorage = Get.put(FileStorage()); ///이미지를 안올릴 때 에러 발생하는 이슈 해결 및 이미지 가져올 때도 마찬가지
    //이미지 storage 및 firestore에 업로드
    await Future.forEach(_images.asMap().entries, (entry) async{
      final index = entry.key;
      final image = entry.value;
      final url=await fileStorage.uploadFile(image, "question/$userName/${title}_$create_date/test_$index");
      img_url.add(url);
      logger.d("returned value from uploadFile: $url");
    });

/*    final url=await fileStorage.uploadFile(_images[0], "question/$userName/${title}_$create_date/test");
    img_url.add(url);
    logger.d("returned value from uploadFile: $url");*/

    // 필수 필드가 작성되었는지 확인
    if (title.isNotEmpty && content.isNotEmpty && category != '글 주제 선택') {
      // 입력받은 데이터로 새로운 question 데이터 생성하여 DB에 생성
      create_date= DateFormat('yy.MM.dd.HH.mm').format(DateTime.now());
      Question newQuestion = Question(
        title: title,
        content: content,
        author: userName!,
        create_date: create_date,
        modify_date: modify_date,
        category: category,
        views_count: views_count,
        isLikeClicked: isLikeClicked,
        answerCount: answerCount,
        img_url: img_url,
      );
      questionFirebase.addQuestion(newQuestion);
      questionSnapshot = await questionFirebase.fetchQuestion(newQuestion);

/*      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => OpenDetailScreen(data: newQuestion, dataId: questionSnapshot!.docs.first.id, dataDoc: questionSnapshot!.docs.first),
        ),
      );*/
        Navigator.of(context).pop();
    }
  }

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져옴
  getImage() async {
    final List<XFile> images = await picker.pickMultiImage();
    if (images != null) {
      images.forEach((e) {
        _images.add(File(e.path));
      });
      //logger.d("getImage: $_images");
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