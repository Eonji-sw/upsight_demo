import 'package:cloud_firestore/cloud_firestore.dart';

class Answer {
  late String question;
  late String content;
  late String author;
  late String create_date;
  late DocumentReference? reference;

  Answer({
    required this.question,
    required this.content,
    required this.author,
    required this.create_date,
    this.reference,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'content': content,
      'author': author,
      'create_date': create_date,
    };
  }

  Answer.fromMap(Map<dynamic, dynamic>? map) {
    question = map?['question'];
    content = map?['content'];
    author = map?['author'];
    create_date = map?['create_date'];
  }

  Answer.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> map = document.data() as Map<String, dynamic>;
    question = map['question'];
    content = map['content'];
    author = map['author'];
    create_date = map['create_date'];
    reference = document.reference;
  }
}