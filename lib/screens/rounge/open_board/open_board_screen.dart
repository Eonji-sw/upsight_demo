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
import '../../../models/model_board.dart';
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

  UserFirebase userFirebase = UserFirebase();

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

      // firebase 객체 초기화
      userFirebase.initDb();

      // Widget의 build 이후에 callback을 받기 위한 코드
     // WidgetsBinding.instance.addPostFrameCallback((_) {
        // 테스트용 코드 : DB에 데이터 한꺼번에 생성하는 함수
        // questionFirebase.generateData();
        // DB 데이터 받아오는 함수
        //fetchData();
    //  });

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
      ///fetchData();
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


  /// 검색된 question 목록을 보여주기 위한 함수
/*  Widget _searchItemWidget(List<String> selectedFilters) {
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
  }*/

  @override
  Widget build(BuildContext context) {
    logger.d("*********Screen build!!***********");

    return ChangeNotifierProvider(
      create: (context)=> SearchFieldModel(),
      builder:(context, child) {

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
                children: [

                  /// 자유게시판, 질문하기 바
                  BoardClickBar(menu: '자유게시판'),
                  BoardClickBar(menu: '질문하기'),
                ],
              ),

              /// 검색창
              Padding(
                padding: const EdgeInsets.all(12),
                child: SearchBar(),
              ),

              /// 필터링
              Container(
                  height: 30,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilteringBar(),

                      ///필터링 바
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: ResetFilterButton(),
                      )
                    ],
                  )
              ),

              /// 정렬 스크롤 버튼
              Align(
                alignment: Alignment.centerLeft,
                child: SortFilterButton(),
              ),

              /// 정보 배너
              GradientBase(),

              /// 게시글 리스트
              Consumer<SearchFieldModel>(
                builder: (context, searchField, _) {
                  // Widget tree containing the Expanded widget
                  logger.d("searchField.searchResults? ${searchField.searchResults}");
                  return
                    searchField.searchResults == null ? Expanded(child:TotalItemWidget()) : Expanded(child:SizedBox());
                },///맨처음에만 null이고 search 후에는 null이 아니니까 뒤쪽꺼가 출력이 되어 totalItemWidget 내의 로직이 안먹히는 중임
              ),
/*              Expanded(
                  child: searchField.searchResults == null ? TotalItemWidget() : Spacer() //searchText.isEmpty ? _totalItemWidget() : _searchItemWidget(selectedFilters) ///게시글 보여주는 위젯
              ),*/
            ],
          ),
        );
      }
    );
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

  /// questions을 선택한 sortFilter로 sort하는 함수
/*  void sortQuestion(List questions) {
    if (sortFilter == '조회순') {
      questions.sort((a, b) => b.views_count.compareTo(a.views_count));
    } else if (sortFilter == '최신순') {
      questions.sort((a, b) => b.create_date.compareTo(a.create_date));
    } else if (sortFilter == '좋아요순') {

    } else if (sortFilter == '댓글순') {
      questions.sort((a, b) => b.answerCount.compareTo(a.answerCount));
    }
  }
  }*/
}


/// 자유게시판, 질문하기 선택바
class BoardClickBar extends StatelessWidget {
  final String menu;
  late var routedScreen;

  BoardClickBar({required this.menu}) {
    if (this.menu == '자유게시판') {
      this.routedScreen = OpenBoardScreen();
    }
    else if (this.menu == '질문하기') {
      this.routedScreen = QnaBoardScreen();
    }
    else{
      logger.e("init error: 메뉴버튼 이름을 제대로 작성하세요");
      this.routedScreen=null;
    }
  }
  Widget build(BuildContext context) {
    return
    Expanded(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        this.routedScreen,
                  ),
                );
              },
              child: Text(menu,
                style: const TextStyle(
                  color: KEY_BLUE,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Padding(
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
    );
  }
}

///검색창 위젯
class SearchBar extends StatelessWidget{
  final TextEditingController searchTextController = TextEditingController();
  SearchBar({super.key});

  emptyTextFormField() {
    searchTextController.clear();
  }

  Widget build(BuildContext context) {
    logger.d("SearchBar widget build");
    final searchField = Provider.of<SearchFieldModel>(context, listen: false);
    return
      TextFormField(
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
            fillColor: WHITE,/////
            contentPadding: EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 16.0),
            prefixIcon: IconButton(
              icon: Icon(Icons.search, color: TEXT_GREY,),
              onPressed: ()=>{searchField.controlSearching(searchTextController.text)},
            ),
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
              borderSide: BorderSide(color: L_GREY,), /// 추가 리펙토링 필요, boarder 싹다 같은 생삭
            ),
          ),
          style: TextStyle(color: BLACK),
          // 키보드의 search 버튼을 누르면 게시물 검색 함수 실행
          textInputAction: TextInputAction.search,
          onFieldSubmitted: searchField.controlSearching,
        );
    }
  }

  ///필터 버튼 위젯
class FilteringBar extends StatelessWidget{//
  Widget build(BuildContext context){
    final searchField = Provider.of<SearchFieldModel>(context, listen: false);
    logger.d("FilteringBar widget build");

    return
    Expanded(
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: List.generate(BoardFilterList.length, (index) {
          String currentFilter = BoardFilterList[index]; // 하자보수, 부동산계약, 임대, 임차, 임대차 키워드들이 담기는 리스트
          bool isSelected = searchField.selectedFilters.contains(currentFilter); //selectedFilter는 현재 고른 필터가 담겨있나 여부

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ElevatedButton(
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
                //토글 시 현재 필터 상태를 넣고 빼는 역할
                searchField.toggleFilter(currentFilter);
                logger.d("${searchField.selectedFilters}");

                if (searchField.selectedFilters.isEmpty) { /// 다 더블 클릭 후 모든 버튼이 비활성화 시에는 다시 원래 질의 보여줌
                  searchField.questions.clear();
                  //searchField.fetchQuestions();
                  //logger.d("searchField.questions: ${searchField.questions}");

                  } else { ///한번만 클릭 시에는 해당 클릭된 필터의 질의만 추출해야함, 여러개 필터 걸면 선택 된 질의만 가져옴
                  logger.d("안비었어");
                    searchField.questions.clear();

                    //searchField.fetchDataWithFilter();
                  }
              },
            ),
          );
        }),
      ),
    );
  }
}

///필터링 초기화 버튼
class ResetFilterButton extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    logger.d("reset filter button widget build");
    final searchField = Provider.of<SearchFieldModel>(context, listen: false);
    return
    ElevatedButton( ///초기화 버튼
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
          searchField.selectedFilters.clear();
          searchField.questions.clear();
          searchField.searchResults=null;
          searchField.fetchQuestions();
      },
    );
  }
}

class SortFilterButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final searchField = Provider.of<SearchFieldModel>(context, listen: false);
    logger.d("sortFilterButton build");
    return
    Selector<SearchFieldModel, String>(
      selector:(_,model)=> model.sortFilter,
      builder:(_, text, __){
        return
          TextButton.icon(
            icon: const Icon(Icons.swap_vert_sharp, color: D_GREY,),
            label: Text(text.toString(),
                        style: const TextStyle(
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
                searchField.setSortFilter(sortFilter);
                logger.d(searchField.sortFilter);
              },
            );
          },
        );
      },
          );}
    );
    throw UnimplementedError();
  }
}

///게시글 컴포넌트 UI
class PostWidget extends StatelessWidget{
  final Question question;
  PostWidget(this.question);
  @override
  Widget build(BuildContext context) {
    //logger.d("Post Widget build");
    return ChangeNotifierProvider<PostFieldModel>(
        create: (context)=> PostFieldModel(question: question),
        builder: (context,child) {
          return
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.all(0),
                title: PostUpperComponent(question),

                ///카테고리, 작성자, 작성일, 제목
                subtitle: PostLowerComponent(question),

                ///내용, 좋아요, 댓글, 조회수-> 좋아요랑 조회수만 뷰모델로 컨트롤 해주면 된다.
                ///따라서 좋아요랑 조회수만 consumer 달아주면 되고 다른 녀석들은 build 되면 안됨

                ///게시글 클릭 시 조회수 증가 & 해당 게시물 안으로 이동
                onTap: () async {
                  final postField= Provider.of<PostFieldModel>(context, listen: false);
                  QuerySnapshot questionSnapshot= await postField.increaseViewsCount();

/*                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            OpenDetailScreen(data: question, dataId: questionSnapshot.docs.first.id, dataDoc: questionSnapshot!.docs.first)),
                  );*/
                },
              ),
              DivideBoard(),
            ],
          );
        }
    );
  }
}

class PostUpperComponent extends StatelessWidget{
  final Question question;
  PostUpperComponent(this.question);

  @override
  Widget build(BuildContext context) {
    //logger.d("PostUpperComponent build");
    return
      Column(
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
      );
  }
}

class PostLowerComponent extends StatelessWidget{
  final Question question;
  PostLowerComponent(this.question);

  @override
  Widget build(BuildContext context) {
    //logger.d("PostLowerComponent build");
    return
      Column(
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

                  Consumer<PostFieldModel>(
                    builder: (context,postField,__) {
                      return Text('조회 ${postField.viewCount}',
                        style: TextStyle(
                          color: TEXT_GREY,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }
                  ),
                ],
              ),
            ],),
          ),
        ],
      );
  }
}

  class TotalItemWidget extends StatelessWidget{
    //final ScrollController _scrollController;
    //TotalItemWidget(this._scrollController);

    Future<void> _fetchQuestions(SearchFieldModel searchField) async {
      if (searchField.questions.isEmpty) {
        ///맨 처음 가져오는 경우
        if(searchField.selectedFilters.isEmpty){
        await searchField.fetchQuestions();
        }
        ///필터 걸린게 없는 경우
        else{

        }
      }
      ///question 리스트 일단 가져와졌고, 필터링을 하고 싶을 때
      else{
        if(searchField.selectedFilters.isNotEmpty){
          searchField.filterQuestions();
          logger.d("searchField.questions: ${searchField.questions}");
        }
      }
    }
    @override
    Widget build(BuildContext context) {
      logger.d("TotalItemWidget build");///fetch question 함수 때문에 얘 결과 받아오는거 때문에 두번 빌드됨
      final searchField = Provider.of<SearchFieldModel>(context, listen: false);

      return FutureBuilder<void>(
        future: _fetchQuestions(searchField),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show a loading indicator while fetching data
          } else if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: searchField.questions.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 3, left: 15, right: 15),
                  child: PostWidget(searchField.questions[index]),
                );
              },
            );
          } else {
            return const Text('Error fetching data'); // Show an error message if the fetch operation fails
          }
        },
      );
    }
  }










/*// 전체 question 목록을 보여주기 위한 위젯
class totalItemWidget extends StatelessWidget {

  Widget build(BuildContext context) {

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

        return Padding(
            padding: EdgeInsets.only(top: 3, bottom: 3, left: 15, right: 15),
            child: _buildItemWidget(questions[index]));
      },
      controller: _scrollController,
    );
  }
}*/
