import 'package:flutter/material.dart';

class GradientBase extends StatelessWidget {
  const GradientBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFFFFC0CB), Color(0xFF87CEFA)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight
        ),
      ),
    );
  }
}