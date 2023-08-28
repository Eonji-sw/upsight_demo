/*
벽면(wall) 생성하는 page
 */

import 'package:board_project/providers/space_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:board_project/models/space.dart';
import 'package:board_project/screens/space/building_board_screen.dart';
import 'package:board_project/providers/question_firestore.dart';
import 'dart:io';
import '../../providers/image_firestorage.dart';
import '../../providers/user_firestore.dart';
import '../login_secure.dart';

class WallCreateScreen extends StatefulWidget {
  // space_detail_screen에서 전달받는 벽면 number 데이터
  final int dataNum;
  final String dataId;
  final String dataName;
  final bool dataType;

  WallCreateScreen({required this.dataNum, required this.dataId, required this.dataName, required this.dataType});

  _WallCreateScreenState createState() => _WallCreateScreenState();
}

class _WallCreateScreenState extends State<WallCreateScreen> {
  SpaceFirebase spaceFirebase = SpaceFirebase();

  // 새로 생성하는 wall model의 각 필드 초기화
  String tag = '';
  String content = '';
  String author = '';
  String create_date = '';
  String modify_date = 'Null';


  // 전달받은 벽면 number 데이터 저장할 변수
  late int wallNum;

  // 전달받은 building id 데이터 저장할 변수
  late String buildingId;

  // 전달받은 space name 저장할 변수
  late String spaceName;

  // 전달받은 space type 저장할 변수
  late bool spaceType;
  final ImagePicker picker = ImagePicker();

  //업로드할 이미지들을 저장할 리스트
  final List<File> _images = [];

  // 현재 로그인한 사용자 name
  late String? userName;

  //firebase storage에 올라간 이미지의 url을 저장할 리스트
  List <String?> img_url = [];

  @override
  void initState() {
    super.initState();
    // 전달받은 벽면 number 데이터 저장
    wallNum = widget.dataNum;
    // 전달받은 building id 데이터 저장
    buildingId = widget.dataId;
    // 전달받은 space name 데이터 저장
    spaceName = widget.dataName;
    // 전달받은 space type 데이터 저장
    spaceType = widget.dataType;

    spaceFirebase.initDb();
    fetchUser();
  }

  // 사용자 데이터를 가져와서 user 변수에 할당하는 함수
  Future<void> fetchUser() async {
    UserFirebase().getUserById(
        FirebaseAuthProvider().authClient.currentUser!.uid)
        .then((result) {
      var userData = result as Map<String, dynamic>;
      if (userData != null) {
        userName = userData["name"];
        logger.d(userName);
        //return user;
      } else {
        logger.e("fetchUser error: 유저 정보를 가져오지 못하였습니다.");
      }
    });
  }


  Future<void> onImageUpload(BuildContext context) async {
    FileStorage fileStorage = Get.put(FileStorage());
    //이미지 storage 및 firestore에 업로드
    await Future.forEach(_images
        .asMap()
        .entries, (entry) async {
      final index = entry.key;
      final image = entry.value;
      final url = await fileStorage.uploadFile(
          image, "wall/$userName/${spaceName}_$create_date/test_$index");
      img_url.add(url);
      logger.d("returned value from uploadFile: $url");
    });
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
            title: Text('벽면 추가'),
          ),
          // appBar 아래 UI 구현 코드
          body: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('선택한 세부 공간의 내용을 입력해주세요.'),
                Divider(thickness: 1),
                // 공간 이름
                Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Text(
                    spaceName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textScaleFactor: 1.4,
                    textAlign: TextAlign.start,
                  ),
                ),
                Divider(
                  thickness: 1,
                ),
                // 공간 타입
                Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Text(
                    spaceType ? '열린 공간' : '닫힌 공간',
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
                    wallNum.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textScaleFactor: 1.4,
                    textAlign: TextAlign.start,
                  ),
                ),
                Divider(
                  thickness: 1,
                ),

                ///이미지 첨부하는 버튼 및 로직 작성

                GestureDetector(
                  onTap: () async {
                    ;
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                          Icons.add_a_photo, size: 48, color: Colors.grey),
                    ),
                  ),
                ),

                TextField(
                  // tag 값이 작성되었는지 확인하여 입력 받은 데이터 저장
                  onChanged: (value) {
                    setState(() {
                      tag = value;
                    });
                  },
                  // 입력하려고 하면 작아지면서 위로 올라가는 애니메이션? UI 코드
                  decoration: InputDecoration(labelText: '태그', prefixText: '#'),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      content = value;
                    });
                  },
                  decoration: InputDecoration(labelText: '내용 입력'),
                ),
                SizedBox(height: 16),
                // 벽면 작성 완료 버튼
                OutlinedButton(
                  onPressed: () {
                    // 모든 필드가 작성되었는지 확인
                    if (tag.isNotEmpty && content.isNotEmpty) {
                      // 입력받은 데이터로 새로운 space 데이터 생성하여 DB에 생성
                      Space newSpace = Space(
                        building: buildingId,
                        name: spaceName,
                        wall: wallNum,
                        type: spaceType,
                        tag: tag,
                        content: content,
                        author: userName!,
                        create_date: DateFormat('yy/MM/dd/HH/mm/ss').format(
                            DateTime.now()),
                        modify_date: modify_date,
                      );

                      spaceFirebase.addSpace(newSpace).then((value) {
                        // 새로 생성된 데이터는 building 목록 screen으로 전환되면서 전달됨
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  BuildingBoardScreen()),
                        );
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
                // 벽면 작성 취소 버튼
                OutlinedButton(
                  onPressed: () {
                    // 이전 화면인 세부 공간 조회 screen으로 전환
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
