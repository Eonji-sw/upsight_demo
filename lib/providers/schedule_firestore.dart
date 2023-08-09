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
    scheduleReference.add(schedule.toMap());
  }

  Future updateSchedule(Schedule schedule) async {
    schedule.reference?.update(schedule.toMap());
  }

  Future deleteSchedule(Schedule schedule) async {
    schedule.reference?.delete();
  }
}
