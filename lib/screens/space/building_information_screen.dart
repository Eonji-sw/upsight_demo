/*
건물(building)의 정보 조회 화면을 보여주는 page
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/building.dart';
import 'package:board_project/providers/building_firestore.dart';
import 'package:board_project/screens/space/building_detail_screen.dart';
import 'package:board_project/screens/space/space_create_screen.dart';
import 'package:board_project/models/space.dart';
import 'package:board_project/providers/space_firestore.dart';
import 'package:board_project/screens/space/space_detail_screen.dart';

class BuildingInformationScreen extends StatefulWidget {
  // building_board_screen에서 전달받는 해당 building 데이터
  final Building data;
  // building_board_screen에서 전달받는 해당 buildingId 데이터
  final String dataId;
  BuildingInformationScreen({required this.data, required this.dataId});

  _BuildingInformationScreenState createState() => _BuildingInformationScreenState();
}

class _BuildingInformationScreenState extends State<BuildingInformationScreen> {
  BuildingFirebase buildingFirebase = BuildingFirebase();
  SpaceFirebase spaceFirebase = SpaceFirebase();
  // DB에서 받아온 space 컬렉션 데이터 담을 list
  List<Space> spaces = [];

  // 전달받은 building 데이터 저장할 변수
  late Building buildingData;
  // 전달받은 buildingId 데이터 저장할 변수
  late String buildingId;

  // 해당 building의 space 데이터들 DocumentSnapshot 저장할 변수
  QuerySnapshot? space_snapshot;
  // 해당 building의 space 목록 길이 초기화
  int spaces_null_len = 0;

  // 공간(space) 하나를 눌렀을 때 상세화면에 넘겨줄 해당 공간 documentId
  late String documentId;

  @override
  void initState() {
    super.initState();
    // 전달받은 building 데이터 저장
    buildingData = widget.data;
    // 전달받은 buildingId 데이터 저장
    buildingId = widget.dataId;
    setState(() {
      buildingFirebase.initDb();
      spaceFirebase.initDb();
      // 해당 building의 space 데이터의 snapshot 저장
      fetchData();
    });
  }

  // 해당 building의 space 데이터의 snapshot 저장하는 함수
  Future<void> fetchData() async {
    // 해당 building의 space 데이터의 DocumentSnapshot() 찾아서 저장
    space_snapshot = await spaceFirebase.spaceReference
        .where('building', isEqualTo: buildingId)
        .get();
    setState(() {
      // 해당 building의 space 목록 길이 저장
      spaces_null_len = space_snapshot!.docs.length;
    });
  }

  // 위젯을 만들고 화면에 보여주는 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar 구현 코드
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('건물 정보 조회'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 건물 이름
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                buildingData.name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.4,
                textAlign: TextAlign.start,
              ),
            ),
            Divider(
              thickness: 1,
            ),
            // 건물 상세 정보 보기
            ListTile(
              title: Text("건물 상세 정보 조회 및 수정"),
              subtitle: Text(buildingData.address),
              onTap: () {
                // 건물의 상세화면을 보여주는 screen으로 화면 전환(인자: 해당 건물 데이터, 해당 건물의 document Id)
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (BuildContext context) => BuildingDetailScreen(data: buildingData, dataId: buildingId)),
                );
              },
            ),
            Divider(
              thickness: 1,
            ),
            // 공간 구성도
            ListTile(
              title: Text("공간 구성도"),
              subtitle: Text("세부 공간을 클릭하여 내용을 조회하고 수정합니다."),
            ),
            Container(
              width: 345.32,
              height: 284.20,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Align(
                // box 가운데에 정렬
                alignment: Alignment.center,
                // 공간 목록이 null일 경우
                child: spaces_null_len == 0
                    ? Text(
                  '생성된 공간이 없습니다', textAlign: TextAlign.center,)
                // 공간 목록이 null이 아닐 경우
                    : ListView.builder(
                    shrinkWrap: true,
                    itemCount: space_snapshot!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      // space의 데이터 저장
                      List<DocumentSnapshot> sortedDocs = space_snapshot!.docs;
                      // space 데이터들을 최신순으로 sort
                      sortedDocs.sort((a, b) {
                        return a['create_date'].compareTo(b['create_date']);
                      });
                      DocumentSnapshot spaceData = sortedDocs[index];

                      return ListTile(
                        title: Text(spaceData['name'] + ' ' + spaceData['wall'].toString()),
                        subtitle: Text(spaceData['type'] == true ? '열린 공간' : '닫힌 공간'),
                        onTap: () {

                          Space space = Space(
                            building: spaceData['building'],
                            name: spaceData['name'],
                            wall: spaceData['wall'],
                            type: spaceData['type'],
                            tag: spaceData['tag'],
                            content: spaceData['content'],
                            author: spaceData['author'],
                            create_date: spaceData['create_date'],
                            modify_date: spaceData['modify_date'],
                            img_url: spaceData['img_url'],
                          );

                          print(spaceData['building']);
                          print(spaceData['name']);
                          print(spaceData['wall']);
                          print(spaceData['type']);
                          print(spaceData['tag']);
                          print(spaceData['content']);
                          print(spaceData['author']);
                          print(spaceData['create_date']);
                          print(spaceData['modify_date']);

                          // 공간의 상세화면을 보여주는 screen으로 화면 전환(인자: 해당 공간 데이터, 해당 공간의 document Id)
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) => SpaceDetailScreen(data: space)),
                          );
                          },
                      );
                    })
              ),
            ),
            Divider(
              thickness: 1,
            ),
            // 세부 공간 추가하기
            ListTile(
              title: Text("세부 공간 추가하기"),
              subtitle: Text("추가할 세부 공간의 타일을 선택해주세요."),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    bool spaceType = false;

                    // 세부 공간 생성 화면을 보여주는 screen으로 화면 전환(인자: 선택한 공간 타입, 해당 건물의 document Id)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) => SpaceCreateScreen(data: spaceType, dataId: buildingId)),
                    );
                  },
                  child: Container(
                    width: 157.59,
                    height: 157.38,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 4,
                          offset: Offset(0, 0),
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('닫힌 공간', textAlign: TextAlign.center,),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(25.0), // 패딩 값 조정 가능
                  child: InkWell(
                    onTap: () {
                      bool spaceType = true;

                      // 세부 공간 생성 화면을 보여주는 screen으로 화면 전환(인자: 선택한 공간 타입, 해당 건물의 document Id)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (BuildContext context) => SpaceCreateScreen(data: spaceType, dataId: buildingId)),
                      );
                    },
                    child: Container(
                      width: 157.59,
                      height: 157.38,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 4,
                            offset: Offset(0, 0),
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('열린 공간', textAlign: TextAlign.center,),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}