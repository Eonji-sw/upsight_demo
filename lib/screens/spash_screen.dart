import 'dart:async';

import 'package:flutter/material.dart';
import 'package:board_project/screens/login_secure.dart';
import 'package:provider/provider.dart';


//맨 첫 화면. login인지 아닌지 여부를 파악해주고 라우팅해준다
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> checkLogin() async {

    final auth = Provider.of<FirebaseAuthProvider>(context, listen: false);
    bool isLogin=false;
    final user=auth.user;
    logger.d("[*] 로그인 상태 : $user");

    if (user!=null) {
      isLogin=true;
    }
    return isLogin;
  }

  void moveScreen() async {
    await checkLogin().then((isLogin) {
      if (isLogin) {
        Navigator.of(context).pushReplacementNamed('/tab');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 500), () {
      moveScreen();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Text("Upsight!?"),
      ),
    );
  }
}