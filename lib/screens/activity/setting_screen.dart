/*
설정 화면
bottomTabBar : x
 */

import 'package:board_project/screens/activity/my_activity_screen.dart';
import 'package:board_project/widgets/divider_sheet.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/size.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isLight = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar
      appBar: AppBar(
        backgroundColor: WHITE,
        centerTitle: true,
        // 제목
        title: Text('설정',
          style: TextStyle(
            color: BLACK,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        // 뒤로가기
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => MyActivityScreen(),
                ),
              );
            },
            color: BLACK,
            icon: Icon(Icons.arrow_back_ios_new)),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none, color: BLACK,)
          ),
        ],
      ),
      // body
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: Container(
            width: 352,
            height: 630.41,
            decoration: ShapeDecoration(
              color: WHITE,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ROUND_BORDER),
              ),
              shadows: [
                BoxShadow(
                  color: BOX_SHADOW_COLOR,
                  blurRadius: 4,
                  offset: Offset(0, 0),
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              children: [
                // 화면 설정
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: Icon(Icons.crop_square, color: D_GREY,),
                  title: Text('화면 설정',
                    style: TextStyle(
                      color: D_GREY,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                          title: Text('라이트 모드',
                            style: TextStyle(
                              color: isLight ? KEY_BLUE : TEXT_GREY,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: true,
                          groupValue: isLight,
                          onChanged: (value) {
                            setState(() {
                              isLight = value!;
                            });
                          }
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                          title: Text('다크 모드',
                            style: TextStyle(
                              color: isLight ? TEXT_GREY : KEY_BLUE,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: false,
                          groupValue: isLight,
                          onChanged: (value) {
                            setState(() {
                              isLight = value!;
                            });
                          }
                      ),
                    ),
                  ],
                ),
                DividerSheet(),
                // 알림 설정
                ListTile(
                  leading: Icon(Icons.notifications_none, color: D_GREY,),
                  title: Text('알림 설정',
                    style: TextStyle(
                      color: D_GREY,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {

                  },
                ),
                DividerSheet(),
                // 메시지 허용 시간
                ListTile(
                  leading: Icon(Icons.email_outlined, color: D_GREY,),
                  title: Text('메시지 허용 시간',
                    style: TextStyle(
                      color: D_GREY,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}