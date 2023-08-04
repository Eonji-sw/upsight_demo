/*
내 활동 홈 화면
 */

import 'package:board_project/widgets/border_activity.dart';
import 'package:board_project/widgets/divider_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../login_secure.dart';

class MyActivityScreen extends StatefulWidget {
  @override
  _MyActivityScreenState createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  bool isWho = true;

  void toggleRole() {
    setState(() {
      isWho = !isWho;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authClient = Provider.of<FirebaseAuthProvider>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 65, bottom: 35),
                  child: Container(
                    width: 358,
                    height: 205.75,
                    decoration: ShapeDecoration(
                        color: WHITE,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                        ),
                        shadows: [
                          BoxShadow(
                            color: BOX_SHADOW_COLOR,
                            blurRadius: 4,
                            offset: Offset(0, 0),
                            spreadRadius: 2,
                          )
                        ]
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 23, bottom: 17),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Image.asset('assets/images/profile.png', width: 54),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('사용자 01',
                                        style: TextStyle(
                                          color: BLACK,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8, right: 8),
                                        child: Container(
                                          width: 3.93,
                                          height: 3.93,
                                          decoration: ShapeDecoration(
                                            color: BLACK,
                                            shape: OvalBorder(),
                                          ),
                                        ),
                                      ),
                                      Text(isWho ? '임대인' : '임차인',
                                        style: TextStyle(
                                          color: D_GREY,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: toggleRole,
                                    child: Row(
                                      children: [
                                        Icon(Icons.cached, color: SUB_BLUE,),
                                        SizedBox(width: 5),
                                        Text('프로필 전환',
                                          style: TextStyle(
                                            color: SUB_BLUE,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: 334.64,
                          height: 1,
                          decoration: BoxDecoration(color: L_GREY),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 13,),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 내 계약
                              BorderActivity(name: '내 계약', icon: Icons.pending_actions,
                                  onTap: () {}
                              ),
                              SizedBox(width: 30,),
                              // 내 게시글
                              BorderActivity(name: '내 게시글', icon: Icons.edit,
                                  onTap: () {}
                              ),
                              SizedBox(width: 30,),
                              // 내 댓글
                              BorderActivity(name: '내 댓글', icon: Icons.messenger_outline,
                                  onTap: () {}
                              ),
                              SizedBox(width: 30,),
                              // 내 좋아요
                              BorderActivity(name: '내 좋아요', icon: Icons.favorite_border,
                                  onTap: () {}
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 384,
                  height: 334,
                  decoration: BoxDecoration(
                    color: WHITE,
                    boxShadow: [
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
                      // 사용자 정보
                      Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: ListTile(
                          leading: Icon(Icons.account_circle_outlined),
                          title: Text('사용자 정보',
                            style: TextStyle(
                              color: D_GREY,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {

                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: DividerSheet(),
                      ),
                      // 설정
                      ListTile(
                        leading: Icon(Icons.settings_outlined),
                        title: Text('설정',
                          style: TextStyle(
                            color: D_GREY,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {

                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: DividerSheet(),
                      ),
                      // 공지사항
                      ListTile(
                        leading: Icon(Icons.error_outline),
                        title: Text('공지사항',
                          style: TextStyle(
                            color: D_GREY,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {

                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: DividerSheet(),
                      ),
                      // 서비스 정보
                      ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('서비스 정보',
                          style: TextStyle(
                            color: D_GREY,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {

                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: DividerSheet(),
                      ),
                      // 로그아웃
                      ListTile(
                        leading: Icon(Icons.logout_outlined),
                        title: Text('로그아웃',
                          style: TextStyle(
                            color: D_GREY,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () async {
                          await authClient.signOut();
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text('로그아웃 되었습니다.')),
                            );
                          final auth = Provider.of<FirebaseAuthProvider>(context, listen: false);
                          if(auth.user == null) Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
      )
    );
  }
}