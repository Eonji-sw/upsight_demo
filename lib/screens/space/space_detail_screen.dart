/*
공간(space)의 상세 화면을 보여주는 page
 */

import 'package:board_project/screens/space/wall_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/space.dart';
import 'package:board_project/providers/space_firestore.dart';
import 'package:board_project/screens/space/wall_create_screen.dart';

class SpaceDetailScreen extends StatefulWidget {
  // building_information_screen에서 전달받는 해당 space 데이터
  final Space data;
  SpaceDetailScreen({required this.data});

  _SpaceDetailScreenState createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends State<SpaceDetailScreen> {
  SpaceFirebase spaceFirebase = SpaceFirebase();
  // DB에서 받아온 wall 컬렉션 데이터 담을 list
  List<Space> walls = [];

  // 전달받은 space 데이터 저장할 변수
  late Space spaceData;

  // 해당 space의 wall 데이터들 DocumentSnapshot 저장할 변수
  QuerySnapshot? wall_snapshot;

  // 벽면 테이블의 헤더행
  List<String> wall_col = ["벽면", "태그", "내용", "수정"];

  @override
  void initState() {
    super.initState();
    // 전달받은 space 데이터 저장
    spaceData = widget.data;

    setState(() {
      spaceFirebase.initDb();
      // 해당 space의 wall 데이터의 snapshot 저장
      fetchData();
    });
  }

  // 해당 space의 wall 데이터의 snapshot 저장하는 함수
  Future<void> fetchData() async {
    // 해당 space의 wall 데이터의 DocumentSnapshot() 찾아서 저장
    wall_snapshot = await spaceFirebase.spaceReference
        .where('name', isEqualTo: spaceData.name)
        .get();
  }

  // 벽면 테이블 생성 함수
  Widget _getDataTable() {
    return DataTable(
      columnSpacing: 20,
      columns: _getColumns(),
      rows: _getRows(),
    );
  }

  // 벽면 테이블 행 생성 함수
  List<DataColumn> _getColumns() {
    List<DataColumn> dataColumn = [];
    for (String c in wall_col) {
      dataColumn.add(DataColumn(label: Text(c, style: TextStyle(fontSize: 12),)));
    }

    return dataColumn;
  }

  // 벽면 테이블 열 생성 함수
  List<DataRow> _getRows() {
    // wall의 데이터 저장
    List<DocumentSnapshot> sortedDocs = wall_snapshot!.docs;
    // wall 데이터들을 최신순으로 sort
    sortedDocs.sort((a, b) {
      return a['create_date'].compareTo(b['create_date']);
    });

    // 최종적으로 반환할 cell이 저장된 list
    List<DataRow> dataRow = [];
    for (var i = 0; i < wall_snapshot!.docs.length; i++) {
      List<DataCell> cells = [];

      cells.add(DataCell(Text(sortedDocs[i]['number'].toString(), style: TextStyle(fontSize: 10),)));
      cells.add(DataCell(Text('#' + sortedDocs[i]['tag'], style: TextStyle(fontSize: 10),)));
      //cells.add(DataCell(ConstrainedBox(constraints: BoxConstraints(maxWidth: 100), child: Text(sortedDocs[i]['content']),)));
      cells.add(DataCell(Text(sortedDocs[i]['content'], style: TextStyle(fontSize: 10),)));
      cells.add(DataCell(Text(sortedDocs[i]['modify_date'], style: TextStyle(fontSize: 10),)));

      dataRow.add(DataRow(cells: cells));
    }
    return dataRow;
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
            // 세부 공간 내용
            ListTile(
              title: Text('세부 공간 내용'),
              subtitle: Text('벽면을 클릭하여 각 세부 내용을 살펴보고,\n내용을 추가 및 수정할 수 있습니다.'),
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
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: ElevatedButton(
                      onPressed: () async {
                        int wallNum = 1;

                        QuerySnapshot snapshot = await spaceFirebase.spaceReference
                            .where('name', isEqualTo: spaceData.name)
                            .where('wall', isEqualTo: wallNum)
                            .get();

                        if (snapshot.docs.isNotEmpty) {
                          String documentId = snapshot.docs.first.id;


                          // 벽면의 상세화면을 보여주는 screen으로 화면 전환
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) => WallDetailScreen(data: spaceData))
                          );

                        } else {
                          // 벽면 생성 화면을 보여주는 screen으로 화면 전환(인자: 선택한 벽면 번호, 해당 공간의 이름)
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => WallCreateScreen(dataNum: wallNum, dataId: spaceData.building, dataName: spaceData.name, dataType: spaceData.type))
                          );
                        }
                      },
                      child: Text('1'),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: ElevatedButton(
                      onPressed: () async {
                        int wallNum = 2;

                        QuerySnapshot snapshot = await spaceFirebase.spaceReference
                            .where('name', isEqualTo: spaceData.name)
                            .where('wall', isEqualTo: wallNum)
                            .get();

                        if (snapshot.docs.isNotEmpty) {

                          // 벽면의 상세화면을 보여주는 screen으로 화면 전환
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => WallDetailScreen(data: spaceData))
                          );

                        } else {
                          // 벽면 생성 화면을 보여주는 screen으로 화면 전환(인자: 선택한 벽면 번호, 해당 공간의 이름)
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => WallCreateScreen(dataNum: wallNum, dataId: spaceData.building, dataName: spaceData.name, dataType: spaceData.type))
                          );
                        }
                      },
                      child: Text('2'),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: ElevatedButton(
                      onPressed: () async {
                        int wallNum = 3;

                        QuerySnapshot snapshot = await spaceFirebase.spaceReference
                            .where('name', isEqualTo: spaceData.name)
                            .where('wall', isEqualTo: wallNum)
                            .get();

                        if (snapshot.docs.isNotEmpty) {

                          // 벽면의 상세화면을 보여주는 screen으로 화면 전환
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => WallDetailScreen(data: spaceData))
                          );

                        } else {
                          // 벽면 생성 화면을 보여주는 screen으로 화면 전환(인자: 선택한 벽면 번호, 해당 공간의 이름)
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => WallCreateScreen(dataNum: wallNum, dataId: spaceData.building, dataName: spaceData.name, dataType: spaceData.type))
                          );
                        }
                      },
                      child: Text('3'),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ElevatedButton(
                      onPressed: () async {
                        int wallNum = 4;

                        QuerySnapshot snapshot = await spaceFirebase.spaceReference
                            .where('name', isEqualTo: spaceData.name)
                            .where('wall', isEqualTo: wallNum)
                            .get();

                        if (snapshot.docs.isNotEmpty) {

                          // 벽면의 상세화면을 보여주는 screen으로 화면 전환
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => WallDetailScreen(data: spaceData))
                          );

                        } else {
                        // 벽면 생성 화면을 보여주는 screen으로 화면 전환(인자: 선택한 벽면 번호, 해당 공간의 이름)
                        Navigator.of(context).push(
                        MaterialPageRoute(
                        builder: (BuildContext context) => WallCreateScreen(dataNum: wallNum, dataId: spaceData.building, dataName: spaceData.name, dataType: spaceData.type))
                        );
                        }
                      },
                      child: Text('4'),
                    ),
                  ),
                ],
              ),
            ),
            // 벽면 내용 리스트
            ListTile(
              title: Text('벽면 내용 리스트'),
            ),
            // Container(
            //   width: 345.32,
            //   height: 284.20,
            //   decoration: ShapeDecoration(
            //     color: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     shadows: [
            //       BoxShadow(
            //         color: Color(0x19000000),
            //         blurRadius: 4,
            //         offset: Offset(0, 0),
            //         spreadRadius: 2,
            //       )
            //     ],
            //   ),
            //   child: Align(
            //     // box 가운데에 정렬
            //     alignment: Alignment.center,
            //     child: SingleChildScrollView(
            //       child: _getDataTable(),
            //     ),
            //   )
            // ),
            SizedBox(height: 16),
          ],
        ),
      )
    );
  }
}