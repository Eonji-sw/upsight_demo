// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../constants/colors.dart';
// import '../models/question.dart';
// import '../screens/rounge/open_board/open_modify_screen.dart';
// import 'button_no.dart';
// import 'button_yes.dart';
// import 'dialog_base.dart';
// import 'listtile_sheet.dart';
//
// class AppbarAction extends StatelessWidget {
//   final String title;
//   final Question question;
//   final QuerySnapshot? answer;
//
//   AppbarAction({Key? key, required this.title, required this.question, required this.answer}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: WHITE,
//       centerTitle: true,
//       // 제목
//       title: Text(title,
//         style: TextStyle(
//           color: BLACK,
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       // 뒤로가기
//       // leading: IconButton(
//       //     onPressed: () {
//       //       Navigator.pop(context);
//       //     },
//       //     color: BLACK,
//       //     icon: Icon(Icons.arrow_back_ios_new)),
//       actions: <Widget>[
//         new IconButton(
//           icon: new Icon(Icons.more_vert, color: BLACK,),
//           onPressed: () {
//             showModalBottomSheet(
//                 backgroundColor: WHITE,
//                 context: context,
//                 builder: (BuildContext context) {
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       ListtileSheet(name: '공유하기', color: BLACK, onTab: () {}),
//                       ListtileSheet(name: '수정', color: BLACK,
//                           onTab: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (BuildContext context) =>
//                                     OpenModifyScreen(data: question),
//                               ),
//                             );
//                           }
//                       ),
//                       ListtileSheet(name: '삭제', color: ALERT_RED,
//                           onTab: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return DialogBase(
//                                   title: '이 글을 삭제하시겠습니까?',
//                                   actions: [
//                                     ButtonNo(
//                                       name: '아니오',
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                       },
//                                     ),
//                                     ButtonYes(
//                                       name: '예',
//                                       onPressed: () async {
//                                         QuerySnapshot snapshot =
//                                         await questionFirebase.questionReference
//                                             .where('title', isEqualTo: question.title)
//                                             .where('content', isEqualTo: question.content)
//                                             .where('author', isEqualTo: question.author)
//                                             .where('create_date', isEqualTo: question.create_date)
//                                             .get();
//
//                                         if (snapshot.docs.isNotEmpty) {
//                                           String documentId = snapshot.docs.first.id;
//                                           // 해당 question 데이터 삭제
//                                           await questionFirebase.questionReference.doc(documentId).delete();
//
//                                           // 해당 question의 answer 데이터 삭제
//                                           for (int i = 0; i < answer!.docs.length; i++) {
//                                             await answerFirebase.answerReference.doc(answer!.docs[i].id).delete();
//                                           }
//
//                                           // 게시물 list screen으로 전환
//                                           Navigator.pushNamed(context, '/test');
//                                         }
//                                       },
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           }),
//                     ],
//                   );
//                 }
//             );
//           },
//         )
//       ],
//     );
//   }
// }