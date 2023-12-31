/*
벽면(wall)의 상세 화면을 보여주는 page
 */

import 'package:board_project/providers/space_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/space.dart';

class WallDetailScreen extends StatefulWidget {
  // space_detail_screen에서 전달받는 해당 space 데이터
  final Space data;
  WallDetailScreen({required this.data});

  _WallDetailScreenState createState() => _WallDetailScreenState();
}

class _WallDetailScreenState extends State<WallDetailScreen> {
  SpaceFirebase spaceFirebase = SpaceFirebase();

  // 전달받은 space 데이터 저장할 변수
  late Space spaceData;

  // 임의로 지정할 user name, 추후 user model과 연결해야해서 DB 연결시켜야함
  late String user;

  @override
  void initState() {
    // 전달받은 space 데이터 저장
    spaceData = widget.data;
    setState(() {
      spaceFirebase.initDb();
    });
    user = 'admin';
  }

  // 위젯을 만들고 화면에 보여주는 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar 구현 코드
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('세부 공간 조회'),
      ),
      // appBar 아래 UI 구현 코드
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 공간 이름
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                spaceData.name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.4,
                textAlign: TextAlign.start,
              ),
            ),
            Divider(
              thickness: 1,
            ),
            // 벽면 번호
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                spaceData.wall.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.4,
                textAlign: TextAlign.start,
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                spaceData.tag,
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.4,
                textAlign: TextAlign.start,
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                spaceData.content,
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.4,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      )
    );
  }
}