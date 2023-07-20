import 'package:board_project/screens/auth_screen.dart';
import 'package:board_project/screens/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

void main() async {
  // calendar 한국어 설정을 위한 코드
  await initializeDateFormatting();
  // 플랫폼 채널의 위젯 바인딩을 보장하기 위한 코드
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase를 초기화 하기 위해서 네이티브 코드를 호출
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //initialRoute: '/',
      //initialRoute: '/auth',
      initialRoute: '/tab',
      routes: {
        //'/': (context) => BoardScreen(),
        '/auth': (context) => AuthScreen(),
        '/tab': (context) => TabScreen(),
      },
      //home: BoardScreen(),
    );
  }
}