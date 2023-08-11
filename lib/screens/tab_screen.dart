import 'package:board_project/screens/activity/my_activity_screen.dart';
import 'package:board_project/screens/calendar_screen.dart';
import 'package:board_project/screens/home_screen.dart';
import 'package:board_project/screens/rounge/open_board/open_board_screen.dart';
import 'package:board_project/screens/space/building_board_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/size.dart';

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  List _pages = [
    HomeScreen(),
    OpenBoardScreen(),
    BuildingBoardScreen(),
    CalendarScreen(),
    MyActivityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
            activeColor: KEY_BLUE,
            items: <BottomNavigationBarItem> [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.forum), label: '라운지'),
              BottomNavigationBarItem(icon: Icon(Icons.layers), label:'공간기록'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 활동'),
            ],
          height: BOTTOM_TAB,
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (context) {
                  return CupertinoPageScaffold(child: _pages[index]);
                },
              );
            case 1:
              return CupertinoTabView(
                builder: (context) {
                  return CupertinoPageScaffold(child: _pages[index]);
                },
              );
            case 2:
              return CupertinoTabView(
                builder: (context) {
                  return CupertinoPageScaffold(child: _pages[index]);
                },
              );
            case 3:
              return CupertinoTabView(
                builder: (context) {
                  return CupertinoPageScaffold(child: _pages[index]);
                },
              );
            case 4:
              return CupertinoTabView(
                builder: (context) {
                  return CupertinoPageScaffold(child: _pages[index]);
                },
              );
          }
          return Container();
        }
    );
  }
}