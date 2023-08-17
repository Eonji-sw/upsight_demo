import 'package:board_project/screens/api_test.dart';
import 'package:board_project/screens/auth_screen.dart';
import 'package:board_project/screens/dl_test_screen.dart';
import 'package:board_project/screens/login_screen.dart';
import 'package:board_project/screens/register_screen.dart';
import 'package:board_project/screens/reset_password_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_board_screen.dart';
import 'package:board_project/screens/spash_screen.dart';
import 'package:board_project/screens/tab_screen.dart';
import 'package:flutter/material.dart';

// Route 이름 정의
const String authRoute = '/';
const String tabRoute = '/tab';
const String boardRoute = '/tab/test';
const String loginRoute='/login';
const String registerRoute= '/register';
const String resetPasswordRoute= '/reset_password';
const String testRoute= '/test';
const String testAPIRoute= '/testAPI';
// Route를 관리하는 함수
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case authRoute:
      return MaterialPageRoute(builder: (context) => SplashScreen());

    case loginRoute:
      return MaterialPageRoute(builder: (context) => LoginScreen());

    case resetPasswordRoute:
      return MaterialPageRoute(builder: (context) => ResetPasswordScreen());

    case registerRoute:
      return MaterialPageRoute(builder: (context) => RegisterScreen());

    case tabRoute:
     return MaterialPageRoute(builder: (context) => TabScreen());

    case boardRoute:
    return MaterialPageRoute(builder: (context) => OpenBoardScreen());

    case testRoute:
      return MaterialPageRoute(builder: (context) => TestScreen());

    //case testAPIRoute:
      //return MaterialPageRoute(builder: (context) => APITestScreen());


    default:
    // 잘못된 Route가 요청된 경우 로그인 페이지로 이동
      return MaterialPageRoute(builder: (context) => SplashScreen());
  }
}
