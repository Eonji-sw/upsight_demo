import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  late String answer;
  late String content;
  late String author;
  late String create_date;
  late DocumentReference? reference;

  Comment({
    required this.answer,
    required this.content,
    required this.author,
    required this.create_date,
    this.reference,
  });

  Map<String, dynamic> toMap() {
    return {
      'answer': answer,
      'content': content,
      'author': author,
      'create_date': create_date,
    };
  }

  Comment.fromMap(Map<dynamic, dynamic>? map) {
    answer = map?['answer'];
    content = map?['content'];
    author = map?['author'];
    create_date = map?['create_date'];
  }

  Comment.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> map = document.data() as Map<String, dynamic>;
    answer = map['answer'];
    content = map['content'];
    author = map['author'];
    create_date = map['create_date'];
    reference = document.reference;
  }}