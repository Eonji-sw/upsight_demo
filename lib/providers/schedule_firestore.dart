import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/schedule.dart';
import 'dart:async';

class ScheduleFirebase {
  late FirebaseFirestore db;
  late CollectionReference scheduleReference;
  late Stream<QuerySnapshot> scheduleStream;

  Future initDb() async {
    db = FirebaseFirestore.instance;
    scheduleReference = FirebaseFirestore.instance.collection('schedule');
    scheduleStream = scheduleReference.snapshots();
  }

  Stream<List<Schedule>> getSchedules() {
    return scheduleStream.map((list) =>
        list.docs.map((doc) =>
            Schedule.fromSnapshot(doc)).toList());
  }
  Future<List<Schedule>> fetchUpdatedSchedules() async {
    QuerySnapshot querySnapshot = await scheduleReference.get();
    return querySnapshot.docs.map((doc) => Schedule.fromSnapshot(doc)).toList();
  }

  Future addSchedule(Schedule schedule) async {
    Map<String, dynamic> scheduleMap = schedule.toMap();

    scheduleMap['start_date'] = {
      'year': schedule.start_date.year,
      'month': schedule.start_date.month,
      'day': schedule.start_date.day,
    };

    scheduleMap['end_date'] = {
      'year': schedule.end_date.year,
      'month': schedule.end_date.month,
      'day': schedule.end_date.day,
    };

    scheduleMap['start_time'] = {
      'hour': schedule.start_time.hour,
      'minute': schedule.start_time.minute,
      'am_pm': schedule.start_time.hour < 12 ? 'AM' : 'PM',
    };

    scheduleMap['end_time'] = {
      'hour': schedule.end_time.hour,
      'minute': schedule.end_time.minute,
      'am_pm': schedule.end_time.hour < 12 ? 'AM' : 'PM',
    };

    await scheduleReference.add(scheduleMap);
  }


  Future updateSchedule(Schedule schedule) async {
    schedule.reference?.update(schedule.toMap());
  }

  Future deleteSchedule(Schedule schedule) async {
    schedule.reference?.delete();
  }
}
