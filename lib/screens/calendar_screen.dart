/*
캘린더 화면
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/colors.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  var _selectedDay;
  var _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      // 달력의 언어
      locale: 'ko_KR',
      // 달력의 최소 날짜
      firstDay: DateTime.now().subtract(Duration(days: 365*10 + 2)),
      // 달력의 최대 날짜
      lastDay: DateTime.now().add(Duration(days: 365*10 + 2)),
      // 달력의 기준 날짜
      focusedDay: _focusedDay,
      // 달력의 높이
      rowHeight: 70,
      // 달력의 요일 높이
      daysOfWeekHeight: 30,

      // 탭하여 선택한 날짜를 선택된 표시로 업데이트
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },

      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: const TextStyle(
          color: BLACK,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          size: 40.0,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          size: 40.0,
        ),
      ),

      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          switch(day.weekday){
            case 1:
              return Center(child: Text('월',
                style: TextStyle(
                  color: D_GREY,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),),
              );
            case 2:
              return Center(child: Text('화',
                style: TextStyle(
                  color: D_GREY,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),),
              );
            case 3:
              return Center(child: Text('수',
                style: TextStyle(
                  color: D_GREY,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),),
              );
            case 4:
              return Center(child: Text('목',
                style: TextStyle(
                  color: D_GREY,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),),
              );
            case 5:
              return Center(child: Text('금',
                style: TextStyle(
                  color: D_GREY,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),),
              );
            case 6:
              return Center(child: Text('토',
                style: TextStyle(
                  color: D_GREY,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),),
              );
            case 7:
              return Center(child: Text('일',
                style: TextStyle(
                  color: ALERT_RED,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),),
              );
          }
        },
      ),

      calendarStyle: CalendarStyle(
        // defaultDay 글자 설정
        defaultTextStyle: TextStyle(
          color: D_GREY,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        // today 모양 설정
        todayDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: D_GREY,
        ),
        // today 글자 설정
        todayTextStyle: TextStyle(
          color: WHITE,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        // outsideDay 노출 x
        outsideDaysVisible: false,
        // cell 내부 정렬
        //cellAlignment: Alignment.topLeft,
        // 가로선 설정
        tableBorder: const TableBorder(
            bottom: BorderSide(
              color: WHITE,
            ),
            horizontalInside: BorderSide(
                color: WHITE
            )
        ),
      ),

      // 임시 evet 설정
      eventLoader: (day) {
        if (day.day % 2 == 0) {
          return ['hi'];
        }
        return [];
      },

    );
  }
}