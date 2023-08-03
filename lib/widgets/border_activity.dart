import 'package:flutter/material.dart';

import '../constants/colors.dart';

class BorderActivity extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const BorderActivity({Key? key, required this.name, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            decoration: ShapeDecoration(
              color: WHITE,
              shape: OvalBorder(
                  side: BorderSide(width: 1, color: L_GREY)
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                    child: Icon(icon, color: SUB_BLUE,)
                )
              ],
            ),
          ),
        ),
        Text(
          name,
          style: TextStyle(
            color: SUB_BLUE,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }
}