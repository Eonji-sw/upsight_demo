import 'package:board_project/widgets/divider_sheet.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/list.dart';

class SheetBase extends StatelessWidget {
  final Function(String) onSortChanged;
  SheetBase({required this.onSortChanged,});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          itemCount: BoardSheetList.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                ListTile(
                  title: Text(BoardSheetList[index],
                    style: TextStyle(
                      color:  BLACK,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    if (onSortChanged != BoardSheetList[index]) {
                      onSortChanged(BoardSheetList[index]);
                    }
                    Navigator.pop(context);
                  },
                ),
                DividerSheet(),
              ],
            );
          },
        )
      ],
    );
  }
}