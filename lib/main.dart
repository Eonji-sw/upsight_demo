import 'package:board_project/router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/colors.dart';
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
      title: 'UpSight',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(seedColor: KEY_BLUE),
        useMaterial3: true,
      ),
      // Route를 관리하는 함수를 설정
      onGenerateRoute: generateRoute,
      initialRoute: authRoute, // 앱을 처음 시작할 때 표시할 첫 페이지 설정
    );
  }
}

// class UserListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('사용자 목록'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('데이터를 불러올 수 없습니다.'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           // 사용자 목록을 ListView로 표시
//           return ListView(
//             children: snapshot.data!.docs.map((document) {
//               // document로부터 사용자 정보 추출
//               String userId = document['userId'];
//               String username = document['username'];
//               String email = document['email'];
//
//               // 사용자 정보를 ListTile로 표시
//               return ListTile(
//                 title: Text(username),
//                 subtitle: Text(email),
//                 // 여기에 원하는 사용자 정보를 활용하는 코드 작성
//                 onTap: () {
//                   // 사용자 정보를 활용한 다른 화면으로 이동 등의 동작 수행
//                 },
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }