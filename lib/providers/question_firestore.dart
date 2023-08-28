import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/question.dart';
import 'dart:async';

import 'package:intl/intl.dart';

import '../constants/size.dart';
import '../screens/login_secure.dart';

class QuestionFirebase {
  late FirebaseFirestore db;
  late CollectionReference questionReference;
  late Stream<QuerySnapshot> questionStream;

  Future initDb() async {
    db = FirebaseFirestore.instance;
    questionReference = FirebaseFirestore.instance.collection('question');
    questionStream = questionReference.snapshots();
  }

  Future fetchQuestion(Question question) async {
    // 해당 question 데이터의 DocumentSnapshot() 찾아서 저장
    final snapshot = await questionReference
        .where('title', isEqualTo: question.title)
        .where('content', isEqualTo: question.content)
        .where('author', isEqualTo: question.author)
        .where('create_date', isEqualTo: question.create_date)
        .get();

    if (snapshot.docs.isNotEmpty) {
      QuerySnapshot? questionSnapshot = snapshot;
      return questionSnapshot;
    }
  }

  Stream <List<Question>> getQuestions() {
    return questionReference.snapshots().map((list) =>
        list.docs.map((doc) =>
            Question.fromSnapshot(doc)).toList());
  }

  // 테스트용 코드 : DB에 데이터 한꺼번에 생성하는 함수
  Future<void> generateData() async {
    // question collection의 reference 받아오는 코드
    CollectionReference questionsRef = questionReference;

    // 22번 question DB 데이터 생성 및 저장
    for (int i = 0; i < 22; i++) {
      await questionsRef.add({
        'title': '$i번째 제목',
        'content': '$i번째 내용',
        'author': 'admin',
        'create_date': DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
        'modify_date': 'Null',
        'category': '$i번째 카테고리',
        'views_count': COMMON_INIT_COUNT,
        'isLikeClicked': false,
      });
    }
  }

  Future addQuestion(Question question) async {
    questionReference.add(question.toMap());
  }

  Future updateQuestion(Question question) async {
    question.reference?.update(question.toMap());
  }

  Future deleteQuestion(Question question) async {
    question.reference?.delete();
  }

  Future <List?> getFile(Question question) async{
    //firestore에서 url 가져오는 함수
    try {
      return question.img_url;
    } catch (e) {
      logger.e('Error: $e');
    }
    return null;
  }
}
