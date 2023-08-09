import 'package:flutter/material.dart';

import '../constants/colors.dart';

class DivideBoard extends StatelessWidget {
  const DivideBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(color: L_GREY),
    );
  }
}