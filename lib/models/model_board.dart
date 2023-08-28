import 'package:board_project/providers/question_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'package:board_project/screens/login_secure.dart';

///검색 관련 뷰모델
class SearchFieldModel extends ChangeNotifier {
  Future<QuerySnapshot<Object?>>? searchResults;
  List<String> selectedFilters=[];
  List <Question> questions=[];
  QuestionFirebase questionFirebase = QuestionFirebase();

  SearchFieldModel(){
    logger.d("searchField provider class initializing");
    questionFirebase.initDb().then((value){logger.d("question fb init complete");});
  }

  //필터 버튼 클릭시 해당 키워드 필터링을 위해 리스트에 필터링 할 버튼의 이름을 담는 함수
  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    logger.d("toggle");
  }
  Future<void> fetchQuestions() async {
    // 처음 앱을 실행했을 때 생성일 순으로 question 데이터를 보여주기 위한 코드


    Query query = questionFirebase.questionReference.orderBy('create_date', descending: true);

    // 가져온 query 데이터의 DocumentSnapshot() 저장
    QuerySnapshot querySnapshot = await query.get();
    // snapshot을 통해 가져온 question 데이터들을 list로 저장
    List<QueryDocumentSnapshot> newItems = querySnapshot.docs;

    // type 맞춰서 기존 questions에 스크롤로 로딩할 때마다 가져온 query 데이터 추가
    questions.addAll(newItems.map((doc) => Question.fromSnapshot(doc)).toList());
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


  controlSearching(String? str) async { ///예외처리 추가해야함
    // 제목만 검색되게 함
    logger.d(str);
    QuestionFirebase questionFirebase = QuestionFirebase();
    await questionFirebase.initDb();
    Future<QuerySnapshot> allQuestions = questionFirebase.questionReference.where('title', isEqualTo: str).get();
    searchResults = allQuestions;
    notifyListeners();
  }
}