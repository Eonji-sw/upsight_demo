import 'package:board_project/providers/question_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:board_project/screens/login_secure.dart';

///검색 관련 뷰모델
class SearchFieldModel extends ChangeNotifier {
  QuerySnapshot? searchResults;
  List<String> selectedFilters=[];
  List <Question> questions=[];
  QuestionFirebase questionFirebase = QuestionFirebase();
  String sortFilter='최신순';

  SearchFieldModel(){
    logger.d("searchField provider class initializing");
    questionFirebase.initDb().then((value){logger.d("question fb init complete // search field model");});
  }

  //필터 버튼 클릭시 해당 키워드 필터링을 위해 리스트에 필터링 할 버튼의 이름을 담는 함수
  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    notifyListeners();
  }

  Future<void> fetchQuestions() async {
    // 처음 앱을 실행했을 때 생성일 순으로 question 데이터를 보여주기 위한 코드
    Query query = questionFirebase.questionReference.orderBy('create_date', descending: true);

    // 가져온 query 데이터의 DocumentSnapshot() 저장
    QuerySnapshot querySnapshot = await query.get();
    // snapshot을 통해 가져온 question 데이터들을 list로 저장
    List<QueryDocumentSnapshot> newItems = querySnapshot.docs;

    // questions 에 Question 모델의 타입을 맞춰서 넣는다.
    questions.addAll(newItems.map((doc) => Question.fromSnapshot(doc)).toList());
    notifyListeners();
  }

  void setSortFilter(String sortFilter){
    this.sortFilter = sortFilter;
    questions.clear();
    notifyListeners();
  }



/*  Future<void> fetchselectedQuestions() async {
    // 필터에 맞는 쿼리 생성
    Query filteredQuery = questionFirebase.questionReference;
    if (selectedFilters.isNotEmpty) {
      filteredQuery = filteredQuery.where('category', whereIn: selectedFilters);
    }
    notifyListeners();
  }*/

  void controlSearching(String? str) async { ///예외처리 추가해야함
    // 제목만 검색되게 함
    logger.d(str);
    QuestionFirebase questionFirebase = QuestionFirebase();
    await questionFirebase.initDb();
    searchResults = await questionFirebase.questionReference.where('title', isEqualTo: str).get();

    //logger.d("$searchResults");
    notifyListeners();
  }
}

///하나의 포스팅 내부 정보를 관리하기 위한 뷰모델
///좋아요 수, 조회 수를 관리하면 된다.
class PostFieldModel extends ChangeNotifier {

  late int viewCount;
  late Question question;
  QuestionFirebase questionFirebase = QuestionFirebase();

  PostFieldModel({required this.question}){
    viewCount=question.views_count;
    questionFirebase.initDb().then((value){logger.d("question fb init complete// post Field Model ");});
  }


  /// 조회수 증가시키는 함수, return 값은 question에 대한 snapshot을 준다.
  Future<QuerySnapshot> increaseViewsCount() async {
    QuerySnapshot questionSnapshot = await questionFirebase.fetchQuestion(question);
    // 해당 question의 조회수를 증가된 값으로 업데이트
    await questionFirebase.questionReference.doc(
        questionSnapshot.docs.first.id).update({
      'views_count': FieldValue.increment(1),
    });
    viewCount+=1;
    notifyListeners();
    return questionSnapshot;
  }
}