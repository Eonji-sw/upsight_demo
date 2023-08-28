/*
건물(building) 생성하는 page
 */

import 'package:flutter/material.dart';
import 'package:board_project/models/building.dart';
import 'package:intl/intl.dart';
import 'package:board_project/providers/building_firestore.dart';

class BuildingCreateScreen extends StatefulWidget {
  _BuildingCreateScreenState createState() => _BuildingCreateScreenState();
}

class _BuildingCreateScreenState extends State<BuildingCreateScreen> {
  BuildingFirebase buildingFirebase = BuildingFirebase();

  // 새로 생성하는 building model의 각 필드 초기화
  String name = '';
  String address = '';
  String author = '';
  String content = '';
  String create_date = '';
  String modify_date = 'Null';
  bool bookmark = false;

  // 임의로 지정할 user name, 추후 user model과 연결해야해서 DB 연결시켜야함
  late String user;

  @override
  void initState() {
    super.initState();
    buildingFirebase.initDb();
    user = 'admin';
  }

  // 위젯을 만들고 화면에 보여주는 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar 구현 코드
      appBar: AppBar(
        // 뒤로가기 버튼 삭제
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        title: Text('건물 추가'),
      ),
        // appBar 아래 UI 구현 코드
        body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              // name 값이 작성되었는지 확인하여 입력 받은 데이터 저장
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              // 입력하려고 하면 작아지면서 위로 올라가는 애니메이션? UI 코드
              decoration: InputDecoration(labelText: '건물 이름'),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  address = value;
                });
              },
              decoration: InputDecoration(labelText: '주소'),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  content = value;
                });
              },
              decoration: InputDecoration(labelText: '내용'),
            ),
            SizedBox(height: 16),
            // 건물 작성 완료 버튼
            OutlinedButton(
                onPressed: () {
                  // 모든 필드가 작성되었는지 확인
                  if (name.isNotEmpty && address.isNotEmpty && content.isNotEmpty) {
                    // 입력받은 데이터로 새로운 building 데이터 생성하여 DB에 생성
                    Building newBuilding = Building(
                      name: name,
                      address: address,
                      content: content,
                      author: user,
                      create_date: DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
                      modify_date: modify_date,
                      bookmark: bookmark,
                    );
                    buildingFirebase.addBuilding(newBuilding).then((value) {
                      // 새로 생성된 데이터는 이전 화면인 건물 list screen으로 전환되면서 전달됨
                      Navigator.of(context).pop(newBuilding);
                    });
                  } else {
                    // 작성되지 않은 필드가 있다면 dialog 띄움
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('입력 오류'),
                          content: Text('모든 필드를 입력해주세요.'),
                          actions: [
                            TextButton(
                              child: Text('확인'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              child: Text('입력 완료'),
            ),
            // 건물 작성 취소 버튼
            OutlinedButton(
              onPressed: () {
                // 이전 화면인 건물 list screen으로 전환
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        ),
      )
    );
  }
}