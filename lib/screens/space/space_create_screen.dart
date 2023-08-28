/*
공간(space) 생성하는 page
 */


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:board_project/models/space.dart';
import 'package:board_project/providers/space_firestore.dart';
import 'package:board_project/screens/space/building_board_screen.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/question_firestorage.dart';
import '../../providers/user_firestore.dart';
import '../login_secure.dart';
import 'package:get/get.dart';

class SpaceCreateScreen extends StatefulWidget {
  // building_information_screen에서 전달받는 type 데이터
  final bool data;
  // building_information_screen에서 전달받는 해당 buildingId 데이터
  final String dataId;
  SpaceCreateScreen({required this.data, required this.dataId});

  _SpaceCreateScreenState createState() => _SpaceCreateScreenState();
}

class _SpaceCreateScreenState extends State<SpaceCreateScreen> {
  SpaceFirebase spaceFirebase = SpaceFirebase();

  // 새로 생성하는 space model의 각 필드 초기화
  String name = '';
  int wall = 0;
  bool type = false;
  String tag = '';
  String content = '';
  String author = '';
  String create_date = '';
  String modify_date = 'Null';

  // 현재 로그인한 사용자 name
  late String? userName;

  // 전달받은 type 데이터 저장할 변수
  late bool spaceType;
  // 전달받은 buildingId 데이터 저장할 변수
  late String buildingId;

  // 게시물의 사진 초기화
  final List<File> _images = [];
  final picker = ImagePicker();
  //받은 이미지들의 fire stoarge에서의 url을 저장
  List img_url =[];

  bool checkCloseValue = false;
  bool checkOpenValue = false;

  @override
  void initState() {
    super.initState();
    // 전달받은 type 데이터 저장
    spaceType = widget.data;
    // 전달받은 buildingId 데이터 저장
    buildingId = widget.dataId;

    if (!spaceType) {
      checkCloseValue = true;
    } else {
      checkOpenValue = true;
    }

    setState(() {
      spaceFirebase.initDb();
    });
    fetchUser();
  }

  // 사용자 데이터를 가져와서 user 변수에 할당하는 함수
  Future<void> fetchUser() async {
    final auth = Provider.of<FirebaseAuthProvider>(context, listen: false);
    UserFirebase().getUserById(auth.authClient.currentUser!.uid)
        .then((result) {
      var userData = result as Map<String, dynamic>;
      if (userData != null) {
        userName = userData["name"];
        logger.d(userName);
        //return user;
      }else{
        logger.e("fetchUser error: 유저 정보를 가져오지 못하였습니다.");
      }
    });
  }

  // 위젯을 만들고 화면에 보여주는 함수
  @override
  Widget build(BuildContext context) {
    logger.d("space create screen build");
    return Scaffold(
      // appBar 구현 코드
      appBar: AppBar(
        // 뒤로가기 버튼 삭제
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        title: Text('세부 공간 추가'),
      ),
      // appBar 아래 UI 구현 코드
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('선택한 세부 공간의 내용을 입력해주세요.'),
            Divider(thickness: 1),
            TextField(
              // name 값이 작성되었는지 확인하여 입력 받은 데이터 저장
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              // 입력하려고 하면 작아지면서 위로 올라가는 애니메이션? UI 코드
              decoration: InputDecoration(labelText: '공간 별칭'),
            ),
            SizedBox(height: 16),
            // 공간 타입 선택
            Column(
              children: [
                Text("공간 타입"),
                CheckboxListTile(
                  title: Text('닫힌 공간'),
                  value: checkCloseValue,
                  onChanged: (newValue) {
                    setState(() {
                      checkCloseValue = newValue!;
                      checkOpenValue = !newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('열린 공간'),
                  value: checkOpenValue,
                  onChanged: (newValue) {
                    setState(() {
                      checkOpenValue = newValue!;
                      checkCloseValue = !newValue!;
                    });
                  },
                ),
              ],
            ),
            Divider(thickness: 1),
            SizedBox(height: 16),
            // 기록할 벽면 선택
            Column(
              children: [
                Text('기록할 벽면 선택'),
                RadioListTile(
                    title: Text('1'),
                    value: 1,
                    groupValue: wall,
                    onChanged: (value) {
                      setState(() {
                        wall = value!;
                      });
                    },
                ),
                RadioListTile(
                  title: Text('2'),
                  value: 2,
                  groupValue: wall,
                  onChanged: (value) {
                    setState(() {
                      wall = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('3'),
                  value: 3,
                  groupValue: wall,
                  onChanged: (value) {
                    setState(() {
                      wall = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('4'),
                  value: 4,
                  groupValue: wall,
                  onChanged: (value) {
                    setState(() {
                      wall = value!;
                    });
                  },
                ),
              ],
            ),
            Divider(
              thickness: 1,
            ),

            //이미지 업로드
            Column(
              children: [Text("이미지 업로드"),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_photo_alternate_outlined),
                      onPressed: () {
                        getImage();
                      },
                    ),
                  ],
                ),
              ],
            ),
            showImage(),

            Divider(
              thickness: 1,
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
            // 공간 작성 완료 버튼
            OutlinedButton(
              onPressed: () async {
                await uploadImage();
                // 모든 필드가 작성되었는지 확인
                if (name.isNotEmpty && wall != 0 && tag.isNotEmpty && content.isNotEmpty) {
                  // 입력받은 데이터로 새로운 space 데이터 생성하여 DB에 생성
                  Space newSpace = Space(
                    building: buildingId,
                    name: name,
                    wall: wall,
                    type: checkOpenValue,
                    tag: tag,
                    content: content,
                    author: userName,
                    create_date: DateFormat('yy/MM/dd/HH/mm/ss').format(DateTime.now()),
                    modify_date: modify_date,
                    img_url: img_url,
                  );

                  spaceFirebase.addSpace(newSpace).then((value) {
                    // 새로 생성된 데이터는 building 목록 screen으로 전환되면서 전달됨
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) => BuildingBoardScreen()),
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
            // 건물 작성 취소 버튼
            OutlinedButton(
              onPressed: () {
                // 이전 화면인 건물 list screen으로 전환
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        )
      )
    );
  }

  uploadImage() async {
    FileStorage fileStorage = Get.put(FileStorage());

    //이미지 storage 및 firestore에 업로드
    await Future.forEach(_images.asMap().entries, (entry) async {
      final index = entry.key;
      final image = entry.value;
      final url = await fileStorage.uploadStorage(
          image, "space/$userName/${name}_$create_date/test_$index");
      img_url.add(url);
      logger.d("returned value from uploadFile: $url");
    });
  }

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져옴
  getImage() async {
    final List<XFile> images = await picker.pickMultiImage();
    if (images != []) {
      images.forEach((e) {
        _images.add(File(e.path));
      });
      logger.d("getImage: $_images");
      setState(() {
      }); ///이미지의 변화를 UI 에 전달, but 전체가 다 빌드된다는 문제가 발생
    }
  }

  // 이미지를 보여주는 위젯
  Widget showImage() {
    logger.d("showImage: $_images");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: 2.5,
        children: _images.map((e) => _gridImage(e)).toList(),
      ),
    );
  }

  // 이미지 UI 위젯
  Widget _gridImage(File image) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _images.remove(image);
                });
              },
              child: Container(
                width: 20,
                height: 20,
                child: Icon(
                  Icons.cancel,
                  size: 15,
                ),
              ),
            )
        )
      ],
    );
  }
}