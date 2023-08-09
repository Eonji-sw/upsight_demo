import 'package:flutter/material.dart';

import '../constants/colors.dart';

class DividerSheet extends StatelessWidget {
  const DividerSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: BoxDecoration(color: L_GREY),
    );
  }
}