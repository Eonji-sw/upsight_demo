import 'package:flutter/material.dart';

import '../constants/colors.dart';

class NullSearch extends StatelessWidget {
  const NullSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.sentiment_dissatisfied_outlined, size: 50,),
            Text(
              '해당 게시글이 없어요',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: BLACK,
                  fontWeight: FontWeight.w500,
                  fontSize: 20
              ),
            )
          ],
        ),
      ),
    );
  }
}