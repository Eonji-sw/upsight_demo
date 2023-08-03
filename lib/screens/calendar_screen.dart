/*
캘린더 화면
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        // 캘린더 보이는 방식
        view: CalendarView.month,
        // 캘린더 오늘 날짜 border 색
        todayHighlightColor: Color(0xFF585858),
        // 캘린더 오늘 날짜 스타일
        todayTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Pretendard Variable',
          fontWeight: FontWeight.w400,
        ),
        // 캘린더 구분선 색
        cellBorderColor: Color(0xFFE5EAEF),

        // 캘린더 헤더 날짜 표시
        headerDateFormat: 'yyy MM',
        // 캘린더 헤더 날짜 스타일
        headerStyle: CalendarHeaderStyle(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center
        ),

        // 캘린더 뷰 요일 스타일
        viewHeaderStyle: ViewHeaderStyle(
          backgroundColor: Color(0xFFE5EAEF),
        ),

        // 캘린더 이전/다음 달 버튼 표시
        showNavigationArrow: true,
      ),
    );
  }
}