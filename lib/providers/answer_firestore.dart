import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/answer.dart';
import 'dart:async';

class AnswerFirebase {
  late CollectionReference answerReference;
  late Stream<QuerySnapshot> answerStream;

  Future initDb() async {
    answerReference = FirebaseFirestore.instance.collection('answer');
    answerStream = answerReference.snapshots();
  }

  List<Answer> getAnswers(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((DocumentSnapshot document) {
      return Answer.fromSnapshot(document);
    }).toList();
  }

  Future addAnswer(Answer answer) async {
    answerReference.add(answer.toMap());
  }

  Future updateAnswer(Answer answer) async {
    answer.reference?.update(answer.toMap());
  }

  Future deleteAnswer(Answer answer) async {
    answer.reference?.delete();
  }
}