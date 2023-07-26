import 'package:board_project/screens/auth_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_board_screen.dart';
import 'package:board_project/screens/tab_screen.dart';
import 'package:flutter/material.dart';

// Route 이름 정의
const String authRoute = '/';
const String tabRoute = '/tab';
const String boardRoute = '/tab/test';

// Route를 관리하는 함수
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case authRoute:
      return MaterialPageRoute(builder: (context) => AuthScreen());
    case tabRoute:
      return MaterialPageRoute(builder: (context) => TabScreen());
    case boardRoute:
      return MaterialPageRoute(builder: (context) => OpenBoardScreen());
    default:
    // 잘못된 Route가 요청된 경우 로그인 페이지로 이동
      return MaterialPageRoute(builder: (context) => AuthScreen());
  }
}