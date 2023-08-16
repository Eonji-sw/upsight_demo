/*
전체 게시글(question) 보여주는 page
무한 스크롤 페이지네이션, 정렬 기능 구현
bottomTabBar : o
 */

import 'package:board_project/providers/question_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:board_project/screens/rounge/open_board/open_create_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:board_project/providers/user_firestore.dart';
import '../../../constants/colors.dart';
import '../../../constants/list.dart';
import '../../../constants/size.dart';
import '../../../widgets/appbar_base.dart';
import '../../../widgets/button_no.dart';
import '../../../widgets/button_yes.dart';
import '../../../widgets/dialog_base.dart';
import '../../../widgets/divider_board.dart';
import '../../../widgets/gradient_base.dart';
import '../../../widgets/null_search.dart';
import '../../../widgets/sheet_base.dart';
import '../qna_board/qna_board_screen.dart';
import 'package:board_project/screens/login_secure.dart';



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

  // 화면에서 한 번에 보여줄 리스트 갯수, 밑으로 스크롤하면 해당 크기만큼 추가로 로딩
  int pageSize = COMMON_PAGE_SIZE;
  // 스크롤하여 가장 마지막에 로드된 question document 위치 저장하는 변수
  DocumentSnapshot? lastDocument;
  // 데이터 로딩 중인지 유무 저장하는 변수
  bool isLoading = false;
  // DB에서 불러온 마지막 데이터인지 유무 저장하는 변수
  bool isLastPage = false;

  // 스크롤컨트롤러 생성
  final ScrollController _scrollController = ScrollController();

  // 해당 게시물 QuerySnapshot
  late QuerySnapshot? questionSnapshot;

  // 화면에 보여질 게시글 정렬 기준(조회순, 최신순, 좋아요순, 댓글순)
  String sortFilter = '최신순';

  // 검색어 저장할 변수
  String searchText = '';

  // 선택된 필터들을 저장할 리스트
  List<String> selectedFilters = [];

  // 댓글 수 변수 정의
  int totalAnswerCount = COMMON_INIT_COUNT;

  // 조회수 반영 개선을 위한 변수
  late int resetViews;
  bool isResetViews = false;

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
        // questionFirebase.generateData();
        // DB 데이터 받아오는 함수
        fetchData();
      });
    });
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
  Future<QuerySnapshot>? searchResults;

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
            return const Center(child: CircularProgressIndicator());
          } else {
            // 로딩 중이 아니라면 빈 위젯 보여줌
            return const SizedBox.shrink();
          }
        }

        isResetViews = false;

        return Padding(padding: EdgeInsets.only(top: 3, bottom: 3, left: 15, right: 15), child: _buildItemWidget(questions[index]));
      },
      controller: _scrollController,
    );
  }

  // 검색된 question 목록을 보여주기 위한 함수
  Widget _searchItemWidget(List<String> selectedFilters) {
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
            return NullSearch();
          } else {
            if (selectedFilters.isNotEmpty) {
              // 검색 결과를 선택한 필터에 맞게 필터링
              searchBoardResult = searchBoardResult
                  .where((question) => selectedFilters.contains(question.category))
                  .toList();
            }

            // 검색된 결과들을 보여주는 UI 코드
            return ListView.builder (
              itemCount: searchBoardResult.length,
              itemBuilder: (BuildContext context, int index) {
                // 현재 index가 questions 크기와 같은지 판별하는 코드
                if (index == searchBoardResult.length) {
                  // 로딩 중이라면 로딩 circle 보여줌
                  if (isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    // 로딩 중이 아니라면 빈 위젯 보여줌
                    return SizedBox.shrink();
                  }
                }

                sortQuestion(searchBoardResult);

                return Padding(padding: EdgeInsets.only(top: 3, bottom: 3, left: 15, right: 15), child: _buildItemWidget(searchBoardResult[index]));
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
        child: AppbarBase(title: '라운지'),
      ),
      // floatingButton
      floatingActionButton: buildFloating(context),
      // body
      body: Column(
        children: <Widget>[
          Row(
            children: [ /// 자유게시판, 질문하기 클래스로 각각 분리하기
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                OpenBoardScreen(),
                          ),
                        );
                      },
                      child: Text('자유게시판',
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
                ),
              ),
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  QnaBoardScreen(),
                            ),
                          );
                        },
                        child: Text('질문하기',
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
                  )
              )
            ],
          ),///
          // 검색창
          Padding( ///검색창 클래스 분리하기
            padding: const EdgeInsets.all(12),
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
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: L_GREY,),
                ),
                // 폼 필드가 활성화되어 있을 때 적용되는 테두리
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: L_GREY,),
                ),
                // 폼 필드 위에 마우스가 올라왔을 때 적용되는 테두리
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: L_GREY,),
                ),
              ),
              style: TextStyle(color: BLACK),
              // 키보드의 search 버튼을 누르면 게시물 검색 함수 실행
              textInputAction: TextInputAction.search,
              onFieldSubmitted: controlSearching,
            ),),
          // 필터링
          Container( ///필터링 클래스 분리
            height: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(BoardFilterList.length, (index) {
                        String currentFilter = BoardFilterList[index];
                        bool isSelected = selectedFilters.contains(currentFilter);

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton( ///필터링 버튼 분리
                            child: Text(currentFilter,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isSelected? KEY_BLUE : TEXT_GREY,
                                height: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(width: 1, color: isSelected? KEY_BLUE : L_GREY),
                              elevation: 0,
                              backgroundColor: WHITE,
                            ),
                            onPressed: () {
                              toggleFilter(currentFilter);
                              setState(() {
                                if (selectedFilters.isEmpty) {
                                  questions.clear();
                                  lastDocument = null;
                                  isLastPage = false;
                                  fetchData();
                                } else {
                                  questions.clear();
                                  lastDocument = null;
                                  isLastPage = false;
                                  fetchDataWithFilter();
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh,
                          color: KEY_BLUE,
                          size: 18,
                        ),
                        SizedBox(width: 1,),
                        Text('초기화',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: KEY_BLUE,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                      backgroundColor: WHITE,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedFilters.clear();
                        questions.clear();
                        lastDocument = null;
                        isLastPage = false;
                        fetchData();
                      });
                    },
                  ),
                )
              ],
            )
          ),
          // 정렬 기준
          Align( ///정렬 기준 클래스 분리
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
                    return SheetBase(
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
          // 정보 배너
          GradientBase(),
          // 게시글 리스트
          Expanded(
              child: searchText.isEmpty ? _totalItemWidget() : _searchItemWidget(selectedFilters)
          ),
        ],
      ),
    );
  }

  void toggleFilter(String filter) {
    setState(() {
      if (selectedFilters.contains(filter)) {
        selectedFilters.remove(filter);
      } else {
        selectedFilters.add(filter);
      }
    });
  }

  Future<void> fetchDataWithFilter() async {
    // 로딩 중인지 DB에서 받아온 데이터가 마지막인지 확인
    if (isLoading || isLastPage) return;

    setState(() {
      isLoading = true;
    });

    // 필터에 맞는 쿼리 생성
    Query filteredQuery = questionFirebase.questionReference;
    if (selectedFilters.isNotEmpty) {
      filteredQuery = filteredQuery.where('category', whereIn: selectedFilters);
    }

    // DB에서 현재 받아온 마지막 데이터가 DB의 마지막 데이터인지 확인
    if (lastDocument != null) {
      // 데이터를 읽어올 시작 document를 lastDocument로 변경
      filteredQuery = filteredQuery.startAfterDocument(lastDocument!);
    }

    // 데이터 수 제한
    filteredQuery = filteredQuery.limit(pageSize);
    // 가져온 query 데이터의 DocumentSnapshot() 저장
    QuerySnapshot querySnapshot = await filteredQuery.get();
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

  // floating action button UI
  Stack buildFloating(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: kBottomNavigationBarHeight, // 아래쪽 여백
          right: 0, // 오른쪽 여백
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DialogBase(
                    title: '자유게시판에 글을 작성하시겠습니까?',
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => OpenCreateScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            backgroundColor: KEY_BLUE,
            elevation: 0, // 그림자를 제거하기 위해 elevation을 0으로 설정
            shape: CircleBorder(),
            child: Icon(Icons.edit, color: WHITE),
          ),
        ),
      ],
    );
  }

  // 게시글 목록을 보여줄 UI 위젯
  Widget _buildItemWidget(Question question) {///Row , Column 별 children 각각 분리
    resetViews = question.views_count;
    return Column(
      children: <Widget>[
        ListTile( ///타일 분리
          contentPadding: EdgeInsets.all(0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 카테고리
                  Stack( ///클래스 분리
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
                          child: Text(question.category,
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
                  Container( ///컨테이너 분리
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
            questionSnapshot = await questionFirebase.fetchQuestion(question);
            // 게시글 중 하나를 눌렀을 경우 해당 게시글의 조회수 증가
            await increaseViewsCount(question);

            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      OpenDetailScreen(data: question, dataId: questionSnapshot!.docs.first.id, dataDoc: questionSnapshot!.docs.first)),
            );

            // 조회수 반영 개선을 위한 코드
            isResetViews = true;
            setState(() {
              resetViews = (questionSnapshot!.docs.first.data() as Map<String, dynamic>)['views_count'];
              if (question.views_count != resetViews) {
                question.views_count = resetViews;
              }
            });
          },
        ),
        DivideBoard(),
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
    await questionFirebase.questionReference.doc(questionSnapshot!.docs.first.id).update({
      'views_count': FieldValue.increment(INCREASE_COUNT),
    });

    setState(() {
      question.views_count += INCREASE_COUNT;
    });
  }
}