import 'package:flutter/material.dart';

import 'divider_sheet.dart';

class ListtileSheet extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onTab;
  const ListtileSheet({Key? key, required this.name, required this.color, required this.onTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
            title: Text(name,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: onTab
        ),
        DividerSheet(),
      ],
    );
  }
}