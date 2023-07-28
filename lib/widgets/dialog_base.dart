import 'package:board_project/widgets/divider_dialog.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class DialogBase extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const DialogBase({Key? key, required this.title, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        height: 195,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BLACK,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: DividerDialog(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft, // 첫 번째 버튼을 왼쪽 아래로 정렬
                    child: actions[0],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight, // 두 번째 버튼을 오른쪽 아래로 정렬
                    child: actions[1],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}