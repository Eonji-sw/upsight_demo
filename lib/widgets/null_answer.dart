import 'package:flutter/material.dart';

import '../constants/colors.dart';

class NullAnswer extends StatelessWidget {
  const NullAnswer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Text('아직 댓글이 없습니다.',
          style: TextStyle(
            color: D_GREY,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}