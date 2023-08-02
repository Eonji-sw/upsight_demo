/*
내 활동 홈 화면
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../login_secure.dart';

class MyActivityScreen extends StatefulWidget {
  @override
  _MyActivityScreenState createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  @override
  Widget build(BuildContext context) {
    final authClient =
    Provider.of<FirebaseAuthProvider>(context, listen: false);
    return Column(
      children: [
        SizedBox(height: 25,),
        Container(
          width: 358,
          height: 205.75,
          decoration: ShapeDecoration(
              color: WHITE,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
              Expanded(
                  child: Align(
                    child: Row(
                      children: [
                        SizedBox(width: 25,),
                        Image.asset('assets/images/profile.png', width: 48.67),
                        SizedBox(width: 13),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('사용자 01 - 임차인',
                              style: TextStyle(
                                color: BLACK,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,),),
                            Row(
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
                          ],
                        )
                      ],
                    ),
                  )
              ),
              Divider(thickness: 1,),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 15),
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {

                            },
                            child: Container(
                              width: 55.39,
                              height: 55.39,
                              decoration: ShapeDecoration(
                                color: WHITE,
                                shape: OvalBorder(),
                                shadows: [
                                  BoxShadow(
                                    color: BOX_SHADOW_COLOR,
                                    blurRadius: 4,
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                      child: Icon(
                                        Icons.pending_actions,
                                        color: SUB_BLUE,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          Text('내 계약',
                            style: TextStyle(
                              color: D_GREY,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),),
                        ],
                      ),
                      SizedBox(width: 20,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {

                            },
                            child: Container(
                              width: 55.39,
                              height: 55.39,
                              decoration: ShapeDecoration(
                                color: WHITE,
                                shape: OvalBorder(),
                                shadows: [
                                  BoxShadow(
                                    color: BOX_SHADOW_COLOR,
                                    blurRadius: 4,
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                      child: Icon(
                                        Icons.edit,
                                        color: SUB_BLUE,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          Text('내 게시글',
                            style: TextStyle(
                              color: D_GREY,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),),
                        ],
                      ),
                      SizedBox(width: 20,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {

                            },
                            child: Container(
                              width: 55.39,
                              height: 55.39,
                              decoration: ShapeDecoration(
                                color: WHITE,
                                shape: OvalBorder(),
                                shadows: [
                                  BoxShadow(
                                    color: BOX_SHADOW_COLOR,
                                    blurRadius: 4,
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                      child: Icon(
                                        Icons.messenger_outline,
                                        color: SUB_BLUE,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          Text('내 댓글',
                            style: TextStyle(
                              color: D_GREY,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),),
                        ],
                      ),
                      SizedBox(width: 20,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {

                            },
                            child: Container(
                              width: 55.39,
                              height: 55.39,
                              decoration: ShapeDecoration(
                                color: WHITE,
                                shape: OvalBorder(),
                                shadows: [
                                  BoxShadow(
                                    color: BOX_SHADOW_COLOR,
                                    blurRadius: 4,
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                      child: Icon(
                                        Icons.favorite_border,
                                        color: SUB_BLUE,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          Text('내 좋아요',
                            style: TextStyle(
                              color: D_GREY,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ),
        SizedBox(height: 25,),
        Container(
          width: 384,
          height: 274.25,
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
          child: Align(
            alignment: Alignment.center,
            child: ListView(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.account_circle_outlined),
                      SizedBox(width: 10,),
                      Text(
                        '사용자 정보',
                        style: TextStyle(
                          color: D_GREY,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {

                  },
                ),
                Divider(thickness: 1,),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.settings_outlined),
                      SizedBox(width: 10,),
                      Text(
                        '설정',
                        style: TextStyle(
                          color: D_GREY,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {

                  },
                ),
                Divider(thickness: 1,),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.error_outline),
                      SizedBox(width: 10,),
                      Text(
                        '공지사항',
                        style: TextStyle(
                          color: D_GREY,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {

                  },
                ),
                Divider(thickness: 1,),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 10,),
                      Text(
                        '서비스 정보',
                        style: TextStyle(
                          color: D_GREY,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {

                  },
                ),
                Divider(thickness: 1,),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.logout_outlined),
                      SizedBox(width: 10,),
                      Text(
                        '로그아웃',
                        style: TextStyle(
                          color: D_GREY,
                          fontSize: 16,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
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
          ),
        ),
      ],
    );
  }
}