/*
건물(building)의 상세 화면을 보여주는 page
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:board_project/models/building.dart';
import 'package:board_project/providers/building_firestore.dart';
import 'package:board_project/screens/space/building_modify_screen.dart';

class BuildingDetailScreen extends StatefulWidget {
  // building_board_screen에서 전달받는 해당 building 데이터
  final Building data;
  // building_board_screen에서 전달받는 해당 buildingId 데이터
  final String dataId;
  BuildingDetailScreen({required this.data, required this.dataId});

  _BuildingDetailScreenState createState() => _BuildingDetailScreenState();
}

class _BuildingDetailScreenState extends State<BuildingDetailScreen> {
  BuildingFirebase buildingFirebase = BuildingFirebase();

  // 전달받은 building 데이터 저장할 변수
  late Building buildingData;
  // 전달받은 buildingId 데이터 저장할 변수
  late String buildingId;

  // 임의로 지정할 user name, 추후 user model과 연결해야해서 DB 연결시켜야함
  late String user;

  @override
  void initState() {
    // 전달받은 building 데이터 저장
    buildingData = widget.data;
    // 전달받은 buildingId 데이터 저장
    buildingId = widget.dataId;
    setState(() {
      buildingFirebase.initDb();
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
        title: Text('건물 상세 정보'),
      ),
      // appBar 아래 UI 구현 코드
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
            // 건물 주소
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                buildingData.address,
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.0,
                textAlign: TextAlign.start,
              ),
            ),
            Divider(
              thickness: 1,
            ),
            // 건물 내용
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                buildingData.content,
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.0,
                textAlign: TextAlign.start,
              ),
            ),
            Divider(
              thickness: 1,
            ),
            // 수정 버튼, 삭제 버튼
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // 수정 버튼
                  OutlinedButton(
                      onPressed: () {
                        // 현재 user와 해당 게시글의 작성자가 같은지 확인
                        if (user == buildingData.author) {
                          // 해당 building 데이터 가지고 수정 screen으로 전환
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) => BuildingModifyScreen(data: buildingData)),
                          );
                        } else {
                          // 현재 user와 해당 게시글의 작성자가 같지 않다면 수정을 할 수 없게 함
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('권한 오류'),
                                  content: Text('해당 게시글의 작성자가 아닙니다.'),
                                  actions: [
                                    TextButton(
                                      child: Text('확인'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                      child: Text('내용 수정'),
                  ),
                  // 삭제 버튼
                  OutlinedButton(
                      onPressed: () {
                        // 현재 user와 해당 게시글의 작성자가 같은지 확인
                        if (user == buildingData.author) {
                          // 해당 building 데이터 가지고 수정 screen으로 전환
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('삭제하기'),
                                  content: Container(
                                    child: Text('삭제하시겠습니까?'),
                                  ),
                                  actions: [
                                    TextButton(
                                        child: Text('삭제'),
                                        onPressed: () async {
                                          QuerySnapshot snapshot = await buildingFirebase.buildingReference
                                              .where('name', isEqualTo: buildingData.name)
                                              .where('address', isEqualTo: buildingData.address)
                                              .where('content', isEqualTo: buildingData.content)
                                              .where('create_date', isEqualTo: buildingData.create_date)
                                              .get();

                                          if (snapshot.docs.isNotEmpty) {
                                            String documentId = snapshot.docs.first.id;
                                            // 해당 building 데이터 삭제
                                            await buildingFirebase.buildingReference.doc(documentId).delete();

                                            // 건물 list screen으로 전환
                                            Navigator.pushNamed(context, '/building');
                                          }
                                        }),
                                    TextButton(
                                        child: Text('취소'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ],
                                );
                              });
                        } else {
                          // 현재 user와 해당 게시글의 작성자가 같지 않다면 삭제를 할 수 없게 함
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('권한 오류'),
                                  content: Text('해당 게시글의 작성자가 아닙니다.'),
                                  actions: [
                                    TextButton(
                                      child: Text('확인'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                    child: Text('삭제'),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

class ImageViewer extends StatelessWidget {
  final List<dynamic>? imageUrls;

  const ImageViewer({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls==null) {
      // Return a placeholder widget or handle the empty case as needed
      return const SizedBox();
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(imageUrls![index]),
          );
        },
      ),
    );
  }
}