import 'package:board_project/screens/auth_screen.dart';
import 'package:board_project/screens/login_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_board_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_detail_screen.dart';
import 'package:board_project/screens/spash_screen.dart';
import 'package:board_project/screens/tab_screen.dart';
import 'package:flutter/material.dart';

// Route 이름 정의
const String authRoute = '/';
const String tabRoute = '/tab';
const String loginRoute='/login';

// Route를 관리하는 함수
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case authRoute:
      return MaterialPageRoute(builder: (context) => TabScreen());

    // auth 로그인/로그아웃 실행
    // case authRoute:
    //   return MaterialPageRoute(builder: (context) => SplashScreen());
    // case loginRoute:
    //   return MaterialPageRoute(builder: (context) => LoginScreen());
    // case tabRoute:
    //   return MaterialPageRoute(builder: (context) => TabScreen());
    default:
    // 잘못된 Route가 요청된 경우 로그인 페이지로 이동
      return MaterialPageRoute(builder: (context) => SplashScreen());
  }
}
