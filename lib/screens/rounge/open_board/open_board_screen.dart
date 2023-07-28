/*
전체 게시글(question) 보여주는 page : 무한 스크롤 페이지네이션, 정렬 기능 구현
 */

import 'package:board_project/providers/question_firestore.dart';
import 'package:board_project/widgets/divider_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:board_project/screens/rounge/open_board/open_create_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:board_project/providers/user_firestore.dart';
import '../../../constants/colors.dart';
import '../../../constants/size.dart';
import '../../../widgets/appbar_base.dart';
import '../qna_board/qna_board_screen.dart';


class OpenBoardScreen extends StatefulWidget {
  @override
  _OpenBoardScreenState createState() => _OpenBoardScreenState();
}

class _OpenBoardScreenState extends State<OpenBoardScreen> {
  // firebase 객체 생성
  QuestionFirebase questionFirebase = QuestionFirebase();
  UserFirebase userFirebase = UserFirebase();

  // DB에서 받아온 question 컬렉션 데이터 담을 list
  List<Question> questions = [];

  // 현재 로그인한 사용자 name
  late String user;

  // 상단바 색상 초기 설정을 위한 현재 게시판 name
  String selectedTab = '자유게시판';

  // 화면에서 한 번에 보여줄 리스트 갯수, 밑으로 스크롤하면 해당 크기만큼 추가로 로딩
  int pageSize = COMMON_PAGE_SIZE;
  // 스크롤하여 가장 마지막에 로드된 question document 위치 저장하는 변수
  DocumentSnapshot? lastDocument;
  // 데이터 로딩 중인지 유무 저장하는 변수
  bool isLoading = false;
  // DB에서 불러온 마지막 데이터인지 유무 저장하는 변수
  bool isLastPage = false;

  // 스크롤컨트롤러 생성
  ScrollController _scrollController = ScrollController();

  // 게시글(question) 하나를 눌렀을 때 detail screen에 넘겨줄 해당 게시글의 documentId, documentSnapshot
  late String questionId;
  late DocumentSnapshot questionDoc;

  // 화면에 보여질 게시글 정렬 기준(조회순, 최신순, 좋아요순, 댓글순)
  String sortFilter = '최신순';

  // 검색어 저장할 변수
  String searchText = '';

  // 댓글 수 변수 정의
  int totalAnswerCount = COMMON_INIT_COUNT;

  // 조회수 반영 개선을 위한 변수
  late int resetViews;
  bool isresetViews = false;

  @override
  void initState() {
    super.initState();
    // _scrollController에 리스너 추가
    _scrollController.addListener(_scrollListener);

    setState(() {
      // firebase 객체 초기화
      questionFirebase.initDb();
      userFirebase.initDb();

      // Widget의 build 이후에 callback을 받기 위한 코드
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        // 테스트용 코드 : DB에 데이터 한꺼번에 생성하는 함수
        //generateData();
        // DB 데이터 받아오는 함수
        fetchData();
      });
    });
  }

  // 테스트용 코드 : DB에 데이터 한꺼번에 생성하는 함수
  Future<void> generateData() async {
    // question collection의 reference 받아오는 코드
    CollectionReference questionsRef = questionFirebase.questionReference;

    // 22번 question DB 데이터 생성 및 저장
    for (int i = 0; i < 22; i++) {
      await questionsRef.add({
        'title': '$i번째 제목',
        'content': '$i번째 내용',
        'author': user,
        'create_date': DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
        'modify_date': 'Null',
        'category': '$i번째 카테고리',
        'views_count': COMMON_INIT_COUNT,
        'isLikeClicked': false,
      });
    }
  }

  // DB 데이터 받아오는 함수
  Future<void> fetchData() async {
    // 로딩 중인지 DB에서 받아온 데이터가 마지막인지 확인
    if (isLoading || isLastPage) return;

    setState(() {
      isLoading = true;
    });

    // 처음 앱을 실행했을 때 생성일 순으로 question 데이터를 보여주기 위한 코드
    Query query = questionFirebase.questionReference.orderBy('create_date', descending: true);

    // DB에서 현재 받아온 마지막 데이터가 DB의 마지막 데이터인지 확인
    if (lastDocument != null) {
      // 데이터를 읽어올 시작 document를 lastDocument로 변경
      query = query.startAfterDocument(lastDocument!);
    }

    // 데이터 수 제한
    query = query.limit(pageSize);
    // 가져온 query 데이터의 DocumentSnapshot() 저장
    QuerySnapshot querySnapshot = await query.get();
    // snapshot을 통해 가져온 question 데이터들을 list로 저장
    List<QueryDocumentSnapshot> newItems = querySnapshot.docs;

    setState(() {
      // type 맞춰서 기존 questions에 스크롤로 로딩할 때마다 가져온 query 데이터 추가
      questions.addAll(newItems.map((doc) => Question.fromSnapshot(doc)).toList());
      // 가져온 query 데이터가 비어있으면 null 저장, 아니라면 가져온 query 데이터의 마지막 값 저장
      lastDocument = newItems.isNotEmpty ? newItems.last : null;

      isLoading = false;
      // 가져온 query 데이터의 크기가 한번에 가져올 데이터 수보다 작다면 마지막 페이지
      if (newItems.length < pageSize) {
        isLastPage = true;
      }
    });
  }

  // 해당 question 데이터 저장하는 변수
  Future<void> fetchQuestion(Question question) async {
    QuerySnapshot snapshot = await questionFirebase.questionReference
        .where('title', isEqualTo: question.title)
        .where('content', isEqualTo: question.content)
        .where('author', isEqualTo: question.author)
        .where('create_date', isEqualTo: question.create_date)
        .get();

    if (snapshot.docs.isNotEmpty) {
      questionDoc = snapshot.docs.first;
      questionId = questionDoc.id;
    }
  }

  // 스크롤 이벤트를 처리하는 함수
  void _scrollListener() {
    // 클라이언트를 가지고 있는지 확인하여 아니라면 종료
    if (!_scrollController.hasClients) return;

    // 최대 스크롤 범위 할당
    final maxScroll = _scrollController.position.maxScrollExtent;
    // 현재 스크롤 위치 할당
    final currentScroll = _scrollController.position.pixels;

    // 스크롤을 최하단까지 내렸을 때 추가로 더 가져올 데이터가 있을 때 실행되는 코드
    if (currentScroll >= maxScroll && !isLoading && !isLastPage) {
      fetchData();
    }
  }

  @override
  void dispose() {
    // _scrollController에 리스너 삭제
    _scrollController.removeListener(_scrollListener);
    // 스크롤컨트롤러 제거
    _scrollController.dispose();
    super.dispose();
  }

  // ** 검색창(상단) 만들기 **
  // 검색창 입력 내용 controller
  TextEditingController searchTextController = TextEditingController();
  // DB에서 검색한 게시글을 가져오는데 활용되는 변수
  Future<QuerySnapshot>? searchResults = null;

  // X 아이콘 클릭시 검색어 삭제
  emptyTextFormField() {
    searchTextController.clear();
  }

  // 검색어 입력 후 submit하게 되면 DB에서 검색어와 일치하거나 포함하는 결과 가져와서 future 변수에 저장
  controlSearching(str) {
    searchText = str;
    // 제목만 검색되게 함
    Future<QuerySnapshot> allQuestions = questionFirebase.questionReference.where('title', isEqualTo: str).get();
    setState(() {
      // DB에서 필터링한 Question들 저장
      searchResults = allQuestions;
    });
  }

  // 전체 question 목록을 보여주기 위한 함수
  Widget _totalItemWidget() {
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (BuildContext context, int index) {
        sortQuestion(questions);

        // 현재 index가 questions 크기와 같은지 판별하는 코드
        if (index == questions.length) {
          // 로딩 중이라면 로딩 circle 보여줌
          if (isLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            // 로딩 중이 아니라면 빈 위젯 보여줌
            return SizedBox.shrink();
          }
        }

        isresetViews = false;

        return Padding(padding: EdgeInsets.only(top: 3, bottom: 3, left: 15, right: 15), child: _buildItemWidget(questions[index]));
      },
      controller: _scrollController,
    );
  }

  // 검색된 question 목록을 보여주기 위한 함수
  Widget _searchItemWidget() {
    return FutureBuilder(
        future: searchResults,
        builder: (context, snapshot) {
          // snapshot에 데이터가 없으면 로딩 circle 보여줌
          if(!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          // 검색어로 검색된 question 데이터들을 저장할 list
          List<Question> searchBoardResult = [];
          snapshot.data!.docs.forEach((document) {
            Question question = Question.fromSnapshot(document);
            // 각 question를 순서대로 list에 추가
            searchBoardResult.add(question);
          });

          // 검색된 결과가 없을 경우
          if(searchBoardResult.isEmpty) {
            return Container(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Icon(Icons.sentiment_dissatisfied_outlined, size: 50,),
                    Text(
                      '해당 게시글이 없어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: BLACK,
                          fontWeight: FontWeight.w500,
                          fontSize: 20
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            // 검색된 결과들을 보여주는 UI 코드
            return ListView.builder (
              itemCount: searchBoardResult.length,
              itemBuilder: (BuildContext context, int index) {
                sortQuestion(searchBoardResult);

                // if (resetViews != searchBoardResult[index].views_count && isresetViews) {
                //   searchBoardResult[index].views_count = resetViews;
                // }

                return _buildItemWidget(searchBoardResult[index]);
              },
              controller: _scrollController,
            );
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppbarBase(title: '라운지', back: false,),
      ),
      // floatingButton
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newQuestion = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => OpenCreateScreen(),
            ),
          );
          if (newQuestion != null) {
            setState(() {
              questions.insert(0, newQuestion);
            });
          }
        },
        backgroundColor: KEY_BLUE,
        elevation: 0, // 그림자를 제거하기 위해 elevation을 0으로 설정
        shape: CircleBorder(),
        child: Icon(Icons.edit, color: WHITE),
      ),
      // body
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedTab = '자유게시판';
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OpenBoardScreen()),
                    );
                  },
                  child: Text(
                    '자유게시판',
                    style: TextStyle(
                      color: selectedTab == '자유게시판' ? KEY_BLUE : TEXT_GREY,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedTab = '질문하기';
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QnaBoardScreen()),

                    );
                  },
                  child: Text(
                    '질문하기',
                    style: TextStyle(
                      color: selectedTab == '질문하기' ? KEY_BLUE : TEXT_GREY,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 검색창
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              // 검색창 controller
              controller: searchTextController,
              decoration: InputDecoration(
                hintText: '글 주제를 검색해보세요.',
                hintStyle: TextStyle(
                  color: TEXT_GREY,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: WHITE,
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                prefixIcon: Icon(Icons.search, color: TEXT_GREY,),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: TEXT_GREY,),
                  onPressed: emptyTextFormField,
                ),
                // 폼 필드의 기본 테두리
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: L_GREY,),
                ),
                // 폼 필드가 활성화되어 있을 때 적용되는 테두리
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: L_GREY,),
                ),
                // 폼 필드 위에 마우스가 올라왔을 때 적용되는 테두리
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: L_GREY,),
                ),
              ),
              style: TextStyle(color: BLACK),
              // 키보드의 search 버튼을 누르면 게시물 검색 함수 실행
              textInputAction: TextInputAction.search,
              onFieldSubmitted: controlSearching,
            ),),
          // 정렬 기준
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: Icon(Icons.swap_vert_sharp, color: D_GREY,),
              label: Text(sortFilter.toString(),
                style: TextStyle(
                  color: D_GREY,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: WHITE,
                  context: context,
                  builder: (BuildContext context) {
                    return ExampleBottomSheet(
                      onSortChanged: (String sortFilter) {
                        setState(() {
                          this.sortFilter = sortFilter;
                          questions.clear();
                          lastDocument = null;
                          isLastPage = false;
                          fetchData();
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          DividerBase(),
          // 게시글 리스트
          Expanded(
              child: searchText.isEmpty ? _totalItemWidget() : _searchItemWidget()
          ),
        ],
      ),
    );
  }

  // 게시글 목록을 보여줄 UI 위젯
  Widget _buildItemWidget(Question question) {
    resetViews = question.views_count;
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 카테고리
                  Stack(
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
                          child: Text('#' + question.category,
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
                  Spacer(),
                  // 작성자
                  Text(question.author,
                    style: TextStyle(
                      color: TEXT_GREY,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Image.asset('assets/images/dot.png', width: 2),
                  ),
                  // 작성일
                  Text(question.create_date,
                    style: TextStyle(
                      color: TEXT_GREY,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 5),
                child:
                // 제목
                Text(question.title,
                  style: TextStyle(
                    color: BLACK,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 내용
              Text(question.content,
                maxLines: MAX_LINE_BOARD,
                overflow: TextOverflow.ellipsis, // 3줄 이상일 경우 ...으로 표시
                style: TextStyle(
                  color: BLACK,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(children: [
                  Container(
                    child: Row(
                      children: [
                        // 좋아요
                        Icon(Icons.favorite_border, size: 14, color: TEXT_GREY,),
                        SizedBox(width: 5,),
                        Text('좋아요',
                          style: TextStyle(
                            color: TEXT_GREY,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 20,),
                        // 댓글
                        Icon(Icons.messenger_outline, size: 14, color: TEXT_GREY,),
                        SizedBox(width: 4,),
                        Text('댓글 ${question.answerCount}',
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
                      Icon(Icons.visibility_outlined, size: 14, color: TEXT_GREY,),
                      SizedBox(width: 5,),
                      Text('조회 ${question.views_count}',
                        style: TextStyle(
                          color: TEXT_GREY,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],),
              ),
            ],
          ),
          onTap: () async {
            await fetchQuestion(question);
            // 게시글 중 하나를 눌렀을 경우 해당 게시글의 조회수 증가
            await increaseViewsCount(question);
            // 게시글의 상세화면을 보여주는 detail screen으로 화면 전환
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      OpenDetailScreen(data: question, dataId: questionId, dataDoc: questionDoc)),
            );

            // 조회수 반영 개선을 위한 코드
            isresetViews = true;
            setState(() {
              resetViews = (questionDoc.data() as Map<String, dynamic>)['views_count'];
              if (question.views_count != resetViews) {
                question.views_count = resetViews;
              }
            });
          },
        ),
        DividerBase(),
      ],
    );
  }

  // questions을 선택한 sortFilter로 sort하는 함수
  void sortQuestion(List questions) {
    if (sortFilter == '조회순') {
      questions.sort((a, b) => b.views_count.compareTo(a.views_count));
    } else if (sortFilter == '최신순') {
      questions.sort((a, b) => b.create_date.compareTo(a.create_date));
    } else if (sortFilter == '좋아요순') {

    } else if (sortFilter == '댓글순') {
      questions.sort((a, b) => b.answerCount.compareTo(a.answerCount));
    }
  }

  // 조회수 증가시키는 함수
  Future<void> increaseViewsCount(Question question) async {
    // 해당 question의 조회수를 증가된 값으로 업데이트
    await questionFirebase.questionReference.doc(questionId).update({
      'views_count': FieldValue.increment(INCREASE_COUNT),
    });

    setState(() {
      question.views_count += INCREASE_COUNT;
    });
  }
}

class ExampleBottomSheet extends StatelessWidget {
  final Function(String) onSortChanged;

  ExampleBottomSheet({
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            '조회순 ',
            style: TextStyle(
              color: BLACK,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            if (onSortChanged != '조회순') {
              onSortChanged('조회순');
            }
            Navigator.pop(context);
          },
        ),
        Container(
          width: 357.26,
          child: Divider(
            color: D_GREY,
            height: 1,
          ),
        ),
        ListTile(
          title: Text(
            '최신순',
            style: TextStyle(
              color: BLACK,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            if (onSortChanged != '최신순') {
              onSortChanged('최신순');
            }
            Navigator.pop(context);
          },
        ),
        Container(
          width: 357.26,
          child: Divider(
            color: D_GREY,
            height: 1,
          ),
        ),
        ListTile(
          title: Text(
            '좋아요순',
            style: TextStyle(
              color: BLACK,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            if (onSortChanged != '좋아요순') {
              onSortChanged('좋아요순');
            }
            Navigator.pop(context);
          },
        ),
        Container(
          width: 357.26,
          child: Divider(
            color: D_GREY,
            height: 1,
          ),
        ),
        ListTile(
          title: Text('댓글순',
            style: TextStyle(
              color: BLACK,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            if (onSortChanged != '댓글순') {
              onSortChanged('댓글순');
            }
            Navigator.pop(context);
          },
        ),
        Container(
          width: 357.26,
          child: Divider(
            color: D_GREY,
            height: 1,
          ),
        ),
      ],
    );
  }
}