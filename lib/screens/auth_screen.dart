/*
로그인 page
 */

import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 사진
            Container(
              width: 316,
              height: 79,
              child: Image.asset('assets/images/logo.png'),
            ),
            Text('Upsight. CO., Ltd',
              style: TextStyle(
                color: D_GREY,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 222,
                    height: 49,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          primary: WHITE,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/tab');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Image.asset('assets/images/google.png', width: 30),
                              SizedBox(width: 10),
                              Text(
                                'Google로 계속하기',
                                style: TextStyle(
                                  color: D_GREY,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 222,
                    height: 49,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            primary: WHITE,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/tab');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Image.asset('assets/images/apple.png',
                                    width: 30),
                                SizedBox(width: 10),
                                Text(
                                  'Apple로 계속하기',
                                  style: TextStyle(
                                    color: D_GREY,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 222,
                    height: 49,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            primary:CALENDAR_YELLOW,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/tab');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Image.asset('assets/images/kakao.png', width: 30),
                                SizedBox(width: 10),
                                Text(
                                  '카카오로 계속하기',
                                  style: TextStyle(
                                    color: D_GREY,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 222,
                    height: 49,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            primary: Color(0xFF1EC800),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/tab');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Image.asset('assets/images/naver.png', width: 30),
                                SizedBox(width: 10),
                                Text(
                                  '네이버로 계속하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ))
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