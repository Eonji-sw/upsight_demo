import 'package:cloud_firestore/cloud_firestore.dart';

class Space {
  late String building;
  late String name;
  late int wall;
  late bool type;
  late String tag;
  late String content;
  late String? author;
  late String create_date;
  late String modify_date;
  late DocumentReference? reference;
  late List<dynamic> img_url;

  Space({
    required this.building,
    required this.name,
    required this.wall,
    required this.type,
    required this.tag,
    required this.content,
    required this.author,
    required this.create_date,
    required this.modify_date,
    required this.img_url,
    this.reference
  });

  Map<String, dynamic> toMap() {
    return {
      'building': building,
      'name': name,
      'wall': wall,
      'type': type,
      'tag': tag,
      'content': content,
      'author': author,
      'create_date': create_date,
      'modify_date': modify_date,
      'img_url': img_url,
    };
  }

  Space.fromMap(Map<dynamic, dynamic>? map) {
    building = map?['building'];
    name = map?['name'];
    wall = map?['wall'];
    type = map?['type'];
    tag = map?['tag'];
    content = map?['content'];
    author = map?['author'];
    create_date = map?['create_date'];
    modify_date = map?['modify_date'];
    img_url= map?['img_url'];
  }

  Space.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> map = document.data() as Map<String, dynamic>;
    building = map['building'];
    name = map['name'];
    wall = map['wall'];
    type = map['type'];
    tag = map['tag'];
    content = map['content'];
    author = map['author'];
    create_date = map['create_date'];
    modify_date = map['modify_date'];
    img_url= map['img_url'];
  }
}