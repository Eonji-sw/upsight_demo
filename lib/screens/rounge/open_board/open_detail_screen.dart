/*
게시글(question)의 상세 화면을 보여주는 page : 좋아요, 댓글 기능 구현
 */

import 'package:board_project/providers/answer_firestore.dart';
import 'package:board_project/providers/user_firestore.dart';
import 'package:board_project/widgets/dialog_base.dart';
import 'package:board_project/widgets/divider_base.dart';
import 'package:board_project/widgets/divider_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:board_project/screens/rounge/open_board/open_modify_screen.dart';
import 'package:board_project/providers/question_firestore.dart';
import 'package:board_project/models/answer.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../../../constants/size.dart';
import '../../../widgets/appbar_action.dart';
import '../../../widgets/button_no.dart';
import '../../../widgets/button_yes.dart';
import '../../../widgets/divider_sheet.dart';
import '../../../widgets/listtile_sheet.dart';

class OpenDetailScreen extends StatefulWidget {
  // infinite_scroll_page에서 전달받는 해당 question 데이터
  final Question data;
  // infinite_scroll_page에서 전달받는 해당 questionId 데이터
  final String dataId;
  // infinite_scroll_page에서 전달받는 해당 questionDoc 데이터
  final DocumentSnapshot dataDoc;

  OpenDetailScreen({required this.data, required this.dataId, required this.dataDoc});

  _OpenDetailScreenState createState() => _OpenDetailScreenState();
}

class _OpenDetailScreenState extends State<OpenDetailScreen> {
  QuestionFirebase questionFirebase = QuestionFirebase();
  AnswerFirebase answerFirebase = AnswerFirebase();
  UserFirebase userFirebase = UserFirebase();

  // 전달받은 question 데이터 저장할 변수
  late Question questionData;
  // 전달받은 questionId 데이터 저장할 변수
  late String questionId;
  // 전달받은 questionId 데이터 저장할 변수
  late DocumentSnapshot questionDoc;

  // 해당 question의 answer 데이터들  DocumentSnapshot 저장할 변수
  QuerySnapshot? answerSnapshot;
  QuerySnapshot? questionSnapshot;

  // 임의로 지정할 user name, 추후 user model과 연결해야해서 DB 연결시켜야함
  late String user;

  // 좋아요 버튼 눌렀는지 유무 저장하는 변수
  bool likeData = false;

  // 댓글 입력할 TextEditingController 선언
  final _commentTextEditController = TextEditingController();

  // 해당 게시글(question)의 답변 목록 길이 초기화
  int answersNullLen = COMMON_INIT_COUNT;

  @override
  void initState() {
    super.initState();
    // 전달받은 question 데이터 저장
    questionData = widget.data;
    // 전달받은 questionId 데이터 저장
    questionId = widget.dataId;
    // 전달받은 questionDoc 데이터 저장
    questionDoc = widget.dataDoc;

    setState(() {
      questionFirebase.initDb();
      answerFirebase.initDb();
      userFirebase.initDb();
      fetchQuestionData();
      // 해당 question의 answer 데이터의 snapshot 저장
      fetchAnswerData();
      fetchUser();
    });
    user = 'admin';
  }

  // 해당 question 데이터의 snapshot 저장하는 함수
  Future<void> fetchQuestionData() async {
    // 해당 question의 answer 데이터의 DocumentSnapshot() 찾아서 저장
    final querySnapshot = await questionFirebase.questionReference
        .where('title', isEqualTo: questionData.title)
        .where('content', isEqualTo: questionData.content)
        .where('author', isEqualTo: questionData.author)
        .where('create_date', isEqualTo: questionData.create_date)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      questionSnapshot = querySnapshot;
    }
  }

  // 해당 question의 answer 데이터의 snapshot 저장하는 함수
  Future<void> fetchAnswerData() async {
    // 해당 question의 answer 데이터의 DocumentSnapshot() 찾아서 저장
    answerSnapshot = await answerFirebase.answerReference
        .where('question', isEqualTo: questionId)
        .get();
    setState(() {
      // 해당 게시글(question)의 답변 목록 길이 저장
      answersNullLen = answerSnapshot!.docs.length;
    });
  }

  Future<void> fetchUser() async {
    final userSnapshot = await userFirebase.userReference.get();
    late DocumentSnapshot document;

    if (userSnapshot.docs.isNotEmpty) {
      document = userSnapshot.docs.first;
    }
    user = (document.data() as Map<String, dynamic>)['user_id'];
  }

  @override
  void dispose() {
    // 댓글 입력하는 TextEditingController 제거
    _commentTextEditController.dispose();
    super.dispose();
  }

  // 위젯을 만들고 화면에 보여주는 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar 구현 코드
      // appBar: PreferredSize(
      //     preferredSize: Size.fromHeight(65),
      //     child: AppbarAction(title: '자유게시판', back: true, question: questionData, answer: answerSnapshot,),
      // ),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: WHITE,
          centerTitle: true,
          // 제목
          title: Text('자유게시판',
            style: TextStyle(
              color: BLACK,
              fontSize: 20,
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.more_vert, color: BLACK,),
              onPressed: () {
                showModalBottomSheet(
                    backgroundColor: WHITE,
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListtileSheet(name: '공유하기', color: BLACK, onTab: () {}),
                          ListtileSheet(name: '수정', color: BLACK,
                              onTab: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        OpenModifyScreen(data: questionData),
                                  ),
                                );
                              }
                          ),
                          ListtileSheet(name: '삭제', color: ALERT_RED,
                              onTab: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DialogBase(
                                      title: '이 글을 삭제하시겠습니까?',
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
                                            await deleteQuestion(context);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                        ],
                      );
                    }
                );
              },
            )
          ],
        ),
      // appBar 아래 UI 구현 코드
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 카테고리
                    Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 10),
                      child: Stack(
                        children: [
                          Container(
                            width: 57,
                            height: 25,
                            decoration: ShapeDecoration(
                              color: L_GREY,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('#' + questionData.category!,
                                style: TextStyle(
                                  color: TEXT_GREY, // 글자의 색상 설정
                                  fontSize: 12,
                                  fontFamily: 'Pretendard Variable',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 제목
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      width: double.infinity,
                      child: Text(
                        questionData.title,
                        style: TextStyle(
                          color: BLACK,
                          fontSize: 18,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                        contentPadding: EdgeInsets.only(left: 15),
                        leading: Image.asset('assets/images/profile.png', width: 32.67),
                        title: Row(
                          children: [
                            Text(questionData.author,
                              style: TextStyle(
                                color: TEXT_GREY,
                                fontSize: 12,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                              ),),
                            Padding(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: Image.asset('assets/images/dot.png', width: 2),
                            ),
                            Text(questionData.create_date,
                              style: TextStyle(
                                color: TEXT_GREY,
                                fontSize: 12,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                              ),),
                          ],
                        )
                    ),
                    DividerBase(),
                    // 내용
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(questionData.content!),
                      ),
                    ),
                    // 좋아요, 댓글수, 조회수
                    Row(children: [
                      Container(
                        child: 
                        // 좋아요
                        Row(
                          children: [
                            SizedBox(width: 15,),
                            InkWell(
                              onTap: () async {
                                await changeLike();
                              },
                              child: Icon(
                                  questionData.isLikeClicked ? Icons.favorite : Icons.favorite_border,
                                  color: questionData.isLikeClicked ? SUB_BLUE : TEXT_GREY,
                                  size: 18
                              ),
                            ),
                            SizedBox(width: 4,),
                            Text('좋아요',
                              style: TextStyle(
                                color: TEXT_GREY,
                                fontSize: 14,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 30,),
                            Icon(Icons.messenger_outline, color: TEXT_GREY, size: 18,),
                            SizedBox(width: 4,),
                            Text(
                              '댓글 ${(questionDoc.data() as Map<String, dynamic>)['answerCount'].toString()}',
                              style: TextStyle(
                                color: TEXT_GREY,
                                fontSize: 14,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      // 조회수
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, color: TEXT_GREY, size: 18),
                          SizedBox(width: 4,),
                          Text(
                            '조회 ${(questionDoc.data() as Map<String, dynamic>)['views_count'].toString()}',
                            style: TextStyle(
                              color: TEXT_GREY,
                              fontSize: 14,
                              fontFamily: 'Pretendard Variable',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 15,)
                    ]),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: DividerBase(),
                    ),
                    // 답변 목록이 null일 경우
                    answersNullLen == COMMON_INIT_COUNT
                        ? Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Text('아직 댓글이 없습니다.',
                          style: TextStyle(
                            color: D_GREY,
                            fontSize: 14,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    )
                    // 답변 목록이 null이 아닐 경우
                        : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: answerSnapshot!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          // answer의 데이터 저장
                          List<DocumentSnapshot> sortedDocs = answerSnapshot!.docs;
                          // answer 데이터들을 최신순으로 sort
                          sortedDocs.sort((a, b) {
                            return a['create_date'].compareTo(b['create_date']);
                          });
                          DocumentSnapshot answerData = sortedDocs[index];

                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.only(left: 15),
                                leading: Image.asset('assets/images/profile.png', width: 32.67),
                                title: Row(
                                  children: [
                                    Text(answerData['author'],
                                      style: TextStyle(
                                        color: BLACK,
                                        fontSize: 12,
                                        fontFamily: 'Pretendard Variable',
                                        fontWeight: FontWeight.w400,
                                      ),),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5, right: 5),
                                      child: Image.asset('assets/images/dot.png', width: 2),
                                    ),
                                    Text(answerData['create_date'],
                                      style: TextStyle(
                                        color: TEXT_GREY,
                                        fontSize: 12,
                                        fontFamily: 'Pretendard Variable',
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return DialogBase(
                                            title: '선택하신 댓글을 삭제하시겠습니까?',
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
                                                    questionFirebase.questionReference.doc(questionId).update({
                                                      'answerCount': FieldValue.increment(DECREASE_COUNT),});

                                                    QuerySnapshot snapshot = await answerFirebase.answerReference
                                                        .where('question', isEqualTo: answerData['question'])
                                                        .where('content', isEqualTo: answerData['content'])
                                                        .where('create_date', isEqualTo: answerData['create_date'])
                                                        .get();
                                                    if (snapshot.docs.isNotEmpty) {
                                                      String documentId = snapshot.docs.first.id;
                                                      await answerFirebase.answerReference.doc(documentId).delete();
                                                      // 게시물 list screen으로 전환
                                                      Navigator.pushNamed(context, '/test');
                                                    }
                                                  }
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  icon: Icon(Icons.delete, color: BLACK, size: 15,),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 65, right: 15, bottom: 10),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(answerData['content']),
                                ),
                              ),
                              DividerSheet(),
                            ],
                          );
                        }),
                  ]
                ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: DividerBase(),
          ),
          // 댓글 입력창
          Container(
            width: 348.84,
            height: 54.22,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 358,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: L_GREY,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: -5,
                  child: Container(
                    width: 300,
                    child: TextFormField(
                      controller: _commentTextEditController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '댓글을 입력해주세요.',
                        hintStyle: TextStyle(
                          color: TEXT_GREY,
                          fontSize: 16,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      textAlignVertical: TextAlignVertical.bottom,
                    ),
                  )
                ),
                Positioned(
                  right: 0,
                  top: -5,
                  child: IconButton(
                    icon: Icon(Icons.send, color: TEXT_GREY,),
                    onPressed: () {
                      // 입력받은 answer 데이터
                      String commentText = _commentTextEditController.text;
                      if (commentText.trim().isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('댓글 오류'),
                              content: Text('댓글을 입력해주세요.'),
                              actions: [
                                TextButton(
                                  child: Text('확인'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        createAnswer(commentText);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 댓글 생성 함수
  void createAnswer(String commentText) {
    Answer newAnswer = Answer(
      question: questionId,
      content: commentText,
      author: user,
      create_date: DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
      //modify_date: 'Null',
    );
    // DB의 answer 컬렉션에 newAnswer document 추가
    answerFirebase.createAnswer(newAnswer);
    questionFirebase.questionReference.doc(questionId).update({
      'answerCount': FieldValue.increment(INCREASE_COUNT),
    });
    // 댓글 입력창을 비웁니다.
    _commentTextEditController.clear();
    // 데이터를 다시 불러옵니다.
    fetchAnswerData();
  }

  // 좋아요 유무 전환 함수
  Future<void> changeLike() async {
    QuerySnapshot snapshot = await questionFirebase.questionReference
        .where('title', isEqualTo: questionData.title)
        .where('content', isEqualTo: questionData.content)
        .where('author', isEqualTo: questionData.author)
        .where('create_date', isEqualTo: questionData.create_date)
        .get();
    // 해당 게시글의 좋아요 유무를 반대로 바꿔줌
    if (snapshot.docs.isNotEmpty) {
      likeData = questionData.isLikeClicked;
      String documentId = snapshot.docs.first.id;
      await questionFirebase.questionReference.doc(documentId).update({
        'isLikeClicked': !questionData.isLikeClicked
      });
      setState(() {
        questionData.isLikeClicked = !likeData;
      });
    }
  }

  // 질문 삭제 함수
  Future<void> deleteQuestion(BuildContext context) async {
    QuerySnapshot snapshot =
    await questionFirebase.questionReference
        .where('title', isEqualTo: questionData.title)
        .where('content', isEqualTo: questionData.content)
        .where('author', isEqualTo: questionData.author)
        .where('create_date', isEqualTo: questionData.create_date)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String documentId = snapshot.docs.first.id;
      // 해당 question 데이터 삭제
      await questionFirebase.questionReference.doc(documentId).delete();

      // 해당 question의 answer 데이터 삭제
      for (int i = 0; i < answerSnapshot!.docs.length; i++) {
        await answerFirebase.answerReference.doc(answerSnapshot!.docs[i].id).delete();
      }

      // 게시물 list screen으로 전환
      Navigator.pushNamed(context, '/test');
    }
  }
}
