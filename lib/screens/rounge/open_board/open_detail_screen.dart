/*
게시글(question)의 상세 화면을 보여주는 page
좋아요, 댓글, 대댓글 기능 구현
bottomTabBar : x
 */


import 'package:board_project/providers/answer_firestore.dart';
import 'package:board_project/providers/user_firestore.dart';
import 'package:board_project/widgets/dialog_base.dart';
import 'package:board_project/widgets/divider_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:board_project/screens/rounge/open_board/open_modify_screen.dart';
import 'package:board_project/providers/question_firestore.dart';
import 'package:board_project/models/answer.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../../../constants/size.dart';
import '../../../models/comment.dart';
import '../../../providers/comment_firestore.dart';
import '../../../providers/question_firestorage.dart';
import '../../../widgets/appbar_action.dart';
import '../../../widgets/null_answer.dart';
import '../../../widgets/button_no.dart';
import '../../../widgets/button_yes.dart';
import '../../../widgets/divider_sheet.dart';
import '../../../widgets/listtile_sheet.dart';
import '../../login_secure.dart';
import 'open_board_screen.dart';


class OpenDetailScreen extends StatefulWidget {
  // infinite_scroll_page에서 전달받는 해당 question, questionId, questionDoc 데이터
  final Question data;
  final String dataId;
  final DocumentSnapshot dataDoc;

  OpenDetailScreen({required this.data, required this.dataId, required this.dataDoc});
  _OpenDetailScreenState createState() => _OpenDetailScreenState();
}

class _OpenDetailScreenState extends State<OpenDetailScreen> {
  // firebase 객체 생성
  QuestionFirebase questionFirebase = QuestionFirebase();
  AnswerFirebase answerFirebase = AnswerFirebase();
  UserFirebase userFirebase = UserFirebase();
  CommentFirebase commentFirebase = CommentFirebase();
  FileStorage fileStorage = FileStorage();

  // 전달받은 question, questionId, questionDoc 데이터 저장할 변수
  late Question questionData;
  late String questionId;
  late DocumentSnapshot questionDoc;

  // 대댓글에 쓰일 answerId 생성
  late String answerId;

  // 해당 question의 answer 데이터들의 DocumentSnapshot 저장할 변수
  QuerySnapshot? answerSnapshot;
  // 해당 answer의 comment 데이터들의 DocumentSnapshot 저장할 변수
  QuerySnapshot? commentSnapshot;

  // 현재 로그인한 사용자 name
  late String? user;

  // 좋아요 버튼 눌렀는지 유무 저장하는 변수
  bool likeData = false;

  // 댓글 입력할 TextEditingController 선언
  final _answerTextEditController = TextEditingController();
  // 댓글/대댓글 입력창 상태 나타내는 변수
  bool isReplying = false;

  // 해당 게시글(question)의 댓글 목록 길이 초기화
  int answersNullLen = COMMON_INIT_COUNT;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      // 현재 로그인된 사용자 정보를 가져와서 user 변수에 할당
      fetchUser();
      // 해당 answer 데이터의 snapshot 저장
      fetchAnswer();
    });
    // 전달받은 question, questionId, questionDoc 데이터 저장
    questionData = widget.data;
    questionId = widget.dataId;
    questionDoc = widget.dataDoc;

    // firebase 객체 초기화
    questionFirebase.initDb();
    answerFirebase.initDb();
    userFirebase.initDb();
    commentFirebase.initDb();
  }

  Future<List?> getImageURL() async {
    try {
      var urls=questionFirebase.getFile(questionData);
        if (urls != null) {
          return urls;
        } else {
          logger.e("not found image");
          return null;
        }
    } catch (e) {
      logger.e("while getting image, error occured: $e");
      return null;
    }
  }


  // 해당 question의 answer 데이터의 snapshot 저장하는 함수
  Future<void> fetchAnswer() async {
    answerSnapshot = await answerFirebase.answerReference
        .where('question', isEqualTo: questionId)
        .get();
      // 해당 게시글(question)의 댓글 목록 길이 저장
    answersNullLen = answerSnapshot!.docs.length;
  }

  // 사용자 데이터를 가져와서 user 변수에 할당하는 함수
/*  Future<void> fetchUser() async {
    final userSnapshot = await userFirebase.userReference.get();
    if (userSnapshot.docs.isNotEmpty) {
      final document = userSnapshot.docs.first;
      setState(() {
        user = (document.data() as Map<String, dynamic>)['user_id'];
        logger.d("open detail - fetch User: $user"); /// null 반환되는 버그
      });
    }
  }*/

  Future<void> fetchUser() async {
    final currentUser = FirebaseAuthProvider().authClient.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      UserFirebase().getUserById(uid)
          .then((result) {
        var userData = result as Map<String, dynamic>;
           user = userData["name"];
          logger.d("open detail - fetch User: $user");
      });
    }
    else {
      logger.e("fetchUser error: 유저 정보를 가져오지 못하였습니다.");
    }
  }



  @override
  void dispose() {
    // 댓글 입력하는 TextEditingController 제거
    _answerTextEditController.dispose();
    super.dispose();
  }


  // 위젯을 만들고 화면에 보여주는 함수
  @override
  Widget build(BuildContext context) {
    logger.d("open detail screen state build call");
    return Scaffold(
      // appBar
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(65),
      //   child: AppbarAction(title: '자유게시판', actions: appbarActions(context),)
      // ),
      appBar: AppBar(
          backgroundColor: WHITE,
          centerTitle: true,
          // 제목
          title: Text('자유게시판',
            style: TextStyle(
              color: BLACK,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          // 뒤로가기
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: BLACK,
              icon: Icon(Icons.arrow_back_ios_new)),
          // 더보기
          actions: appbarActions(context),
      ),
      // body
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
                              child: Text(questionData.category,
                                style: TextStyle(
                                  color: TEXT_GREY,
                                  fontSize: 12,
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
                      child: Text(questionData.title,
                        style: TextStyle(
                          color: BLACK,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                        contentPadding: EdgeInsets.only(left: 15, right: 15),
                        visualDensity: VisualDensity.compact,
                        leading: Image.asset('assets/images/profile.png', width: 32.67),
                        title: Row(
                          children: [
                            // 작성자
                            Text(questionData.author,
                              style: TextStyle(
                                color: TEXT_GREY,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),),
                            Padding(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: Image.asset('assets/images/dot.png', width: 2),
                            ),
                            // 작성일
                            Text(questionData.create_date,
                              style: TextStyle(
                                color: TEXT_GREY,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),),
                          ],
                        ),
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

                    /*image container 들어갈 부분*/
                    FutureBuilder<List?>(
                        future: getImageURL(),
                        builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasData) {
                              final imageUrls = snapshot.data!;
                              logger.d("image container value: $imageUrls");
                              return ImageViewer(imageUrls: imageUrls);
                            } else if(snapshot.hasError){
                              logger.e("error occured while getting url snapshot: ${snapshot.hasError}");
                              return const SizedBox();
                            } else {
                              logger.d('Image not found');
                              return const SizedBox();
                            }
                        }
                    ),

                    // 좋아요, 댓글수, 조회수
                    Row(children: [
                      Container(
                        child:
                        Row(
                          children: [
                            SizedBox(width: 15,),
                            // 좋아요
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
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 30,),
                            // 댓글
                            Icon(Icons.messenger_outline, color: TEXT_GREY, size: 18,),
                            SizedBox(width: 4,),
                            Text('댓글 ${(questionDoc.data() as Map<String, dynamic>)['answerCount'].toString()}',
                              style: TextStyle(
                                color: TEXT_GREY,
                                fontSize: 14,
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
                          Text('조회 ${questionData.views_count}',
                            style: TextStyle(
                              color: TEXT_GREY,
                              fontSize: 14,
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
                    // 댓글 목록이 null일 경우
                    answersNullLen == COMMON_INIT_COUNT
                        ? NullAnswer()
                    // 댓글 목록이 null이 아닐 경우
                        : answerShow(),
                  ]
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: DividerBase(),
          ),
          // 댓글 입력창
          buildInputText(context),
        ],
      ),
    );
  }

  // 댓글 입력창
  Container buildInputText(BuildContext context) {
    return Container(
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
                      controller: _answerTextEditController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '댓글을 입력해주세요.',
                        hintStyle: TextStyle(
                          color: TEXT_GREY,
                          fontSize: 16,
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
                    String answerText = _answerTextEditController.text;
                    if (answerText.trim().isEmpty) {
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
                      isReplying ? createComment(answerText) : createAnswer(answerText);
                    }
                  },
                ),
              ),
            ],
          ),
        );
  }

  // 대댓글 목록 보여주는 화면
  Widget commentShow(String answerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: commentFirebase.getCommentsByAnswer(answerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 대기 중일 때 로딩 인디케이터 표시
        }
        if (snapshot.hasData && snapshot.data!.docs.length > 0) {
          // 대댓글이 있을 경우 리스트뷰로 표시
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              // comment의 데이터 저장
              List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
              // comment 데이터들을 최신순으로 sort
              sortedDocs.sort((a, b) {
                return a['create_date'].compareTo(b['create_date']);
              });
              // 현재 comment data
              DocumentSnapshot commentData = sortedDocs[index];

              return Container(
                color: L_GREY,
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 10),
                  child: Container(
                    decoration: ShapeDecoration(
                        color: WHITE,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),
                        )
                    ),
                    child: Column(
                      children: [
                        ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.only(left: 5, top: 10),
                            visualDensity: VisualDensity.compact,
                            leading: Image.asset('assets/images/profile.png', width: 32.67),
                            title: Row(
                              children: [
                                // 작성자
                                Text(commentData['author'],
                                  style: TextStyle(
                                    color: BLACK,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),),
                                Padding(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: Image.asset('assets/images/dot.png', width: 2),
                                ),
                                // 작성일
                                Text(commentData['create_date'],
                                  style: TextStyle(
                                    color: TEXT_GREY,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),),
                              ],
                            ),
                            // 삭제 버튼
                            trailing:IconButton(
                              icon: Icon(Icons.more_vert, color: BLACK,),
                              onPressed: () {
                                showModalBottomSheet(
                                    backgroundColor: WHITE,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          user == commentData['author'] ? ListtileSheet(name: '수정', color: BLACK, onTab: () {})
                                              : ListtileSheet(name: '신고', color: BLACK, onTab: () {}),
                                          user == commentData['author'] ? ListtileSheet(name: '삭제', color: ALERT_RED,
                                              onTab: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return DialogBase(
                                                      title: '선택하신 대댓글을 삭제하시겠습니까?',
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
                                                              await commentFirebase.commentReference.doc(commentData.reference.id).delete();
                                                              Navigator.of(context).pop();
                                                            }
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }) : ListtileSheet(name: '차단', color: BLACK, onTab: () {}),
                                        ],
                                      );
                                    }
                                );
                              },
                            )
                        ),
                        // 내용
                        Padding(
                          padding: EdgeInsets.only(left: 63, right: 18, bottom: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(commentData['content']),
                          ),
                        ),
                        DividerSheet(),
                      ],
                    )
                  ),
                ),
              );
            },
          );
        } else {
          // 대댓글이 없을 경우 '대댓글 없음' 메시지를 표시
          return SizedBox();
        }
      },
    );
  }

  // 댓글 목록 보여주는 화면
  ListView answerShow() {
    return ListView.builder(
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
          // 현재 answer data
          DocumentSnapshot answerData = sortedDocs[index];
          // 현재 answer referenceId 저장
          answerId = answerData.reference.id;

          return Column(
            children: [
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.only(left: 3, top: 10),
                leading: Image.asset('assets/images/profile.png', width: 32.67),
                title: Row(
                  children: [
                    // 작성자
                    Text(answerData['author'],
                      style: TextStyle(
                        color: BLACK,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 5),
                      child: Image.asset('assets/images/dot.png', width: 2),
                    ),
                    // 작성일
                    Text(answerData['create_date'],
                      style: TextStyle(
                        color: TEXT_GREY,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),),
                  ],
                ),
                // 삭제 버튼
                trailing: IconButton(
                  icon: Icon(Icons.more_vert, color: BLACK,),
                  onPressed: () {
                    showModalBottomSheet(
                        backgroundColor: WHITE,
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              user == answerData['author'] ? ListtileSheet(name: '수정', color: BLACK, onTab: () {})
                                  : ListtileSheet(name: '신고', color: BLACK, onTab: () {}),
                              user == answerData['author'] ? ListtileSheet(name: '삭제', color: ALERT_RED,
                                  onTab: () {
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
                                                  await deleteAnswer(answerData, context);
                                                }
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }) : ListtileSheet(name: '차단', color: BLACK, onTab: () {}),
                            ],
                          );
                        }
                    );
                  },
                )
              ),
              // 내용
              Padding(
                padding: EdgeInsets.only(left: 63, right: 18),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(answerData['content']),
                ),
              ),
              // 답글 버튼
              Padding(
                padding: EdgeInsets.only(right: 15,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {},
                      icon: Icon(Icons.favorite_border, size: 15 ,color: TEXT_GREY,),
                      label: Text("좋아요",
                        style: TextStyle(
                          color: TEXT_GREY,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(60, 22),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 0.50, color: L_GREY),
                            borderRadius: BorderRadius.circular(4)
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    ElevatedButton.icon(
                      onPressed: () async {
                        QuerySnapshot snapshot = await answerFirebase.answerReference
                            .where('content', isEqualTo: answerData['content'])
                            .where('author', isEqualTo: answerData['author'])
                            .where('create_date', isEqualTo: answerData['create_date'])
                            .where('question', isEqualTo: answerData['question'])
                            .get();

                        if (snapshot.docs.isNotEmpty) {
                          late DocumentSnapshot answerDoc = snapshot.docs.first;
                          answerId = answerDoc.id;

                          isReplying = true;
                        }
                      },
                      icon: Icon(Icons.messenger_outline, size: 15 ,color: TEXT_GREY,),
                      label: Text("답글",
                        style: TextStyle(
                          color: TEXT_GREY,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(53.26, 22),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 0.50, color: L_GREY),
                            borderRadius: BorderRadius.circular(4)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DividerSheet(),
              commentShow(answerId),
            ],
          );
        });
  }

  // 대댓글 생성 함수
  void createComment(String commentText) async {
    // 입력받은 데이터로 새로운 answer 데이터 생성하여 DB에 생성
    Comment newComment = Comment(
      answer: answerId,
      content: commentText,
      author: user!,
      create_date: DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
    );
    await commentFirebase.addComment(newComment);
    // 대댓글 입력창 초기화
    _answerTextEditController.clear();
  }

  // appbar 더보기
  List<Widget> appbarActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.more_vert, color: BLACK,),
        onPressed: () {
          showModalBottomSheet(
              backgroundColor: WHITE,
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListtileSheet(name: '공유하기', color: BLACK, onTab: () {}),
                    user == questionData.author ? ListtileSheet(name: '수정', color: BLACK,
                        onTab: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  OpenModifyScreen(data: questionData, dataId: questionId, dataDoc: questionDoc),
                            ),
                          );
                        }
                    ) : ListtileSheet(name: '신고', color: BLACK, onTab: () {}),
                    user == questionData.author ? ListtileSheet(name: '삭제', color: ALERT_RED,
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
                        }) : ListtileSheet(name: '차단', color: BLACK, onTab: () {}),
                  ],
                );
              }
          );
        },
      )
    ];
  }

  // 댓글 삭제 함수
  Future<void> deleteAnswer(DocumentSnapshot<Object?> answerData, BuildContext context) async {
    // question의 댓글수 감소
    questionFirebase.questionReference.doc(questionId).update({
      'answerCount': FieldValue.increment(DECREASE_COUNT),
    });

    QuerySnapshot snapshot = await answerFirebase.answerReference
        .where('question', isEqualTo: answerData['question'])
        .where('content', isEqualTo: answerData['content'])
        .where('create_date', isEqualTo: answerData['create_date'])
        .get();
    if (snapshot.docs.isNotEmpty) {
      String documentId = snapshot.docs.first.id;
      await answerFirebase.answerReference.doc(documentId).delete();

      commentSnapshot = await commentFirebase.commentReference
          .where('answer', isEqualTo: documentId)
          .get();

      // 해당 answer의 comment 데이터 삭제
      for (int i = 0; i < commentSnapshot!.docs.length; i++) {
        await commentFirebase.commentReference.doc(commentSnapshot!.docs[i].id).delete();
      }
      // 데이터를 다시 불러옴
      fetchAnswer();
      Navigator.of(context).pop();
    }
  }

  // 댓글 생성 함수
  createAnswer(String answerText) {
    // 입력받은 데이터로 새로운 answer 데이터 생성하여 DB에 생성
    Answer newAnswer = Answer(
      question: questionId,
      content: answerText,
      author: user!,
      create_date: DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
    );
    answerFirebase.addAnswer(newAnswer);

    // question의 댓글수 증가
    questionFirebase.questionReference.doc(questionId).update({
      'answerCount': FieldValue.increment(INCREASE_COUNT),
    });

    // 댓글 입력창 초기화
    _answerTextEditController.clear();
    // 데이터를 다시 불러옴
    fetchAnswer();
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
      await questionFirebase.questionReference.doc(questionId).update({
        'isLikeClicked': !questionData.isLikeClicked
      });
      setState(() {
        questionData.isLikeClicked = !likeData;
      });
    }
  }

  // 질문 삭제 함수
  Future<void> deleteQuestion(BuildContext context) async {
    await questionFirebase.questionReference.doc(questionId).delete();
    // 해당 question의 answer 데이터 삭제
    for (int i = 0; i < answerSnapshot!.docs.length; i++) {
      await answerFirebase.answerReference.doc(answerSnapshot!.docs[i].id).delete();
    }

    // 게시물 list screen으로 전환
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => OpenBoardScreen(),
      ),
    );
  }

}

class ImageViewer extends StatelessWidget {
  final List<dynamic>? imageUrls;

  const ImageViewer({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls==null) {
      // Return a placeholder widget or handle the empty case as needed
      return const SizedBox();
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(imageUrls![index]),
          );
        },
      ),
    );
  }
}

