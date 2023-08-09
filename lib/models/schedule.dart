import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  late String id; // 일정의 고유 ID
  late String title; // 일정/이벤트 제목
  late DateTime start_date; // 시작 일정
  late DateTime end_date; // 종료 일정
  late DateTime start_time; // 시작 시간
  late DateTime end_time; // 종료 시간
  late String? description; // 일정/이벤트 상세 내용 (선택적)
  late int type; // 캘린더에 표시될 색상
  late bool isSwitched; //종일인지 아닌지 전환
  late DocumentReference? reference;

  Schedule({
    required this.id,
    required this.title,
    required this.start_date,
    required this.end_date,
    required this.start_time,
    required this.end_time,
    required this.isSwitched,
    this.description,
    required this.type,
    this.reference,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_time': start_time,
      'start_date': start_date,
      'end_time': end_time,
      'end_date': end_date,
      'description': description,
      'type': type,
      'isClicked': isSwitched,
    };
  }

  Schedule.fromMap(Map<dynamic, dynamic>? map) {
    id = map?['id'];
    title = map?['title'];
    start_time = map?['start_time'];
    start_date = map?['start_date'];
    end_time = map?['end_time'];
    end_date = map?['end_date'];
    description = map?['description'];
    type = map?['type'];
    isSwitched = map?['isSwitched'];
  }


  Schedule.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic>? map = document.data() as Map<String, dynamic>?;

    if (map != null) {
      id = map['id'] ?? '';
      title = map['title'] ?? '';

      if (map['start_date'] is Timestamp) {
        start_date = (map['start_date'] as Timestamp).toDate();
      } else {
        start_date = DateTime.now();
      }

      if (map['start_time'] is Timestamp) {
        start_time = (map['start_time'] as Timestamp).toDate();
      } else {
        start_time = DateTime.now();
      }

      if (map['end_time'] is Timestamp) {
        end_time = (map['end_time'] as Timestamp).toDate();
      } else {
        end_time = DateTime.now();
      }

      if (map['end_date'] is Timestamp) {
        end_date = (map['end_date'] as Timestamp).toDate();
      } else {
        end_date = DateTime.now();
      }

      description = map['description'] ?? '';
      type = map['type'] ?? 0;
      reference = document.reference;
      isSwitched = map['isSwitched'] ?? false;
    } else {
      id = '';
      title = '';
      start_date = DateTime.now();
      start_time = DateTime.now();
      end_time = DateTime.now();
      end_date = DateTime.now();
      description = '';
      type = 0;
      isSwitched = false;
    }
  }





}
