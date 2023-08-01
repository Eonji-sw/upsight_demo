import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/comment.dart';
import 'dart:async';

class CommentFirebase {
  late CollectionReference commentReference;
  late Stream<QuerySnapshot> commentStream;

  Future initDb() async {
    commentReference = FirebaseFirestore.instance.collection('comment');
    commentStream = commentReference.snapshots();
  }

  List<Comment> getComments(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((DocumentSnapshot document) {
      return Comment.fromSnapshot(document);
    }).toList();
  }

  Future addComment(Comment comment) async {
    commentReference.add(comment.toMap());
  }

  Future updateComment(Comment comment) async {
    comment.reference?.update(comment.toMap());
  }

  Future deleteComment(Comment comment) async {
    comment.reference?.delete();
  }

  Stream<QuerySnapshot> getCommentsByAnswer(String answerId) {
    // 해당 댓글에 대한 대댓글을 가져오는 쿼리
    return commentReference.where('answer', isEqualTo: answerId).snapshots();
  }
}

