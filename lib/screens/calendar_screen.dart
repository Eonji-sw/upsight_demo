/*
캘린더 화면
 */
import 'package:board_project/models/user.dart';
import 'package:flutter/cupertino.dart';

import '../../../constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:board_project/providers/schedule_firestore.dart';
import 'package:board_project/models/schedule.dart';
import 'dart:async';
import '../providers/user_firestore.dart';


class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  UserFirebase userFirebase = UserFirebase();
  ScheduleFirebase scheduleFirebase = ScheduleFirebase();

  // 스케줄 데이터 스트림을 가져와 scheduleStream에 할당
  late Stream<List<Schedule>> scheduleStream; // 스케줄 데이터 스트림

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  DateTime selectedEndTime = DateTime.now();

  String text = '';
  List lst = ['청약', '목표', '일정'];
  bool switchValue = false;
  int? selectedRadio = 0;
  //스케줄 이름, 상세 내용 초기화
  String title = '';
  String description = '';
  // 현재 로그인한 사용자 name
  late String user;


  List<Meeting> meetings = <Meeting>[];

  // 사용자 데이터를 가져와서 user 변수에 할당하는 함수
  Future<void> fetchUser() async {
    final userSnapshot = await userFirebase.userReference.get();

    if (userSnapshot.docs.isNotEmpty) {
      final document = userSnapshot.docs.first;
      setState(() {
        user = (document.data() as Map<String, dynamic>)['user_id'];
      });
    }
  }



  @override
  void initState() {
    super.initState();
    initializeData();
    scheduleFirebase.initDb();
    userFirebase.initDb();// 비동기 메서드 호출
    fetchUser();
  }


// 비동기로 데이터를 초기화하고 가져오는 작업 수행
  Future<void> initializeData() async {
    // firebase 객체 초기화
    scheduleFirebase.initDb();
    // 스케줄 데이터 스트림을 가져와 scheduleStream에 할당
    scheduleStream = scheduleFirebase.getSchedules();
    // 파이어베이스에서 데이터 가져와 meetings 리스트 초기화
    List<Schedule> fetchedSchedules = await scheduleFirebase.fetchUpdatedSchedules();
    // Convert fetched schedules to Meeting objects and store in the meetings list
    meetings = fetchedSchedules.map((schedule) {
      return Meeting(
        schedule.title,
        schedule.start_date,
        schedule.end_date,
        schedule.type == 0 ? const Color(0xFF0F8644) : const Color(0xFF1565C0),
        schedule.isSwitched,
      );
    }).toList();

    // 화면을 다시 그리도록 갱신
    setState(() {});
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCalendar(
          view: CalendarView.month,
          dataSource: MeetingDataSource(meetings),
          monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
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
        floatingActionButton: buildFloating(context));
  }
  Stack buildFloating(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: kBottomNavigationBarHeight, // 아래쪽 여백
          right: 0, // 오른쪽 여백
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                title = ''; // 제목 초기화
                selectedRadio = 0; // 라디오 버튼 초기화
                selectedStartDate = DateTime.now(); // 시작 날짜 초기화
                selectedStartTime = DateTime.now(); // 시작 시간 초기화
                selectedEndDate = DateTime.now(); // 종료 날짜 초기화
                selectedEndTime = DateTime.now(); // 종료 시간 초기화
                switchValue = false; // 스위치 값 초기화
                description = ''; // 설명 초기화
              });
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      backgroundColor: Colors.white,
                      content: Container(
                        decoration: BoxDecoration(
                          // color: Colors.white, // 원하는 배경색으로 변경
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: StatefulBuilder(
                          builder: (__, StateSetter setDialogState) {
                            return Container(
                              height: 457.41,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: List<Widget>.generate(3, (int index) {
                                      return Container(
                                        width: 120,
                                        child: RadioListTile<int>(
                                          value: index,
                                          groupValue: selectedRadio,
                                          onChanged: (int? value) {
                                            if (value != selectedRadio) { // 값이 변경되었을 때만 setState 호출
                                              setDialogState(() => selectedRadio = value);
                                              // setState(() => text = 'MyStatefulWidget $value'); 라디오 버튼 선택에따라 ui 업데이트 되는 것 방지
                                            }
                                          },
                                          title: Text(lst[index],
                                            style: TextStyle(
                                              color: Color(0xFFA7ABAD),
                                              fontSize: 12,
                                              fontFamily: 'Pretendard Variable',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  // 일정 제목
                                  Container(
                                    width: 305,
                                    height:40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: L_GREY ,width: 1),
                                      color: L_GREY,
                                    ),
                                    child: TextField(
                                      onChanged: (value){
                                        setState(() {
                                          title=value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: '스케줄 이름',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  //구분선 추가
                                  Divider(height: 1, color: L_GREY),
                                  Icon(
                                    Icons.query_builder,
                                  ),
                                  Row(
                                    children: [
                                      // 일정 시작 날짜 및 종료 날짜
                                      CupertinoButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: 300,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: CupertinoDatePicker(
                                                        initialDateTime: selectedStartDate,
                                                        onDateTimeChanged: (DateTime newDate) {
                                                          setDialogState(() => selectedStartDate = newDate);
                                                          // setState(() {
                                                          //   selectedStartDate = newDate;
                                                          //   print(selectedStartDate);
                                                          // });
                                                        },
                                                        mode: CupertinoDatePickerMode.date,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: CupertinoDatePicker(
                                                        initialDateTime: selectedEndDate,
                                                        onDateTimeChanged: (DateTime newDate) {
                                                          setDialogState(() => selectedEndDate = newDate);
                                                          // setState(() {
                                                          //   selectedEndDate = newDate;
                                                          //   print(selectedEndDate);
                                                          // });
                                                        },
                                                        mode: CupertinoDatePickerMode.date,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              // 일정 시작 날짜 텍스트
                                              '${DateFormat('yyyy.MM.dd').format(selectedStartDate)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 20,),
                                            Text(
                                              // 일정 종료 날짜 텍스트
                                              '${DateFormat('yyyy.MM.dd').format(selectedEndDate)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      // 일정 시작 및 종료 시간
                                      CupertinoButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: 300,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: CupertinoDatePicker(
                                                        initialDateTime: selectedStartTime,
                                                        onDateTimeChanged: (DateTime newDate) {
                                                          setDialogState(() => selectedStartTime = newDate);
                                                          // setState(() {
                                                          //   selectedStartTime = newDate;
                                                          // });
                                                        },
                                                        mode: CupertinoDatePickerMode.time,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: CupertinoDatePicker(
                                                        initialDateTime: selectedEndTime,
                                                        onDateTimeChanged: (DateTime newDate) {
                                                          setDialogState(() => selectedEndTime = newDate);
                                                          // setState(() {
                                                          //   selectedEndTime = newDate;
                                                          // });
                                                        },
                                                        mode: CupertinoDatePickerMode.time,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            // 시작 시간 텍스트
                                            Text(
                                              '${DateFormat('HH.mm').format(selectedStartTime)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 20,),
                                            // 종료 시간 텍스트
                                            Text(
                                              '${DateFormat('HH.mm').format(selectedEndTime)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  CupertinoSwitch(
                                    value: switchValue,
                                    activeColor: CupertinoColors.activeBlue,
                                    onChanged: (bool value) {
                                      print("Switch value changed: $value");
                                      // setState(() {
                                      //   switchValue = value;
                                      // });
                                      setDialogState(() => switchValue = value);
                                    },
                                  ),
                                  //구분선 추가
                                  Divider(height: 1, color: L_GREY),
                                  SizedBox(height: 20),

                                  //스케줄 상세 내용
                                  Row(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child:
                                          Icon(Icons.sticky_note_2_outlined)
                                        // Image.asset('assets/images/document.png', width: 24, height:24, ),
                                      ),
                                      SizedBox(
                                        width: 290,
                                        child: TextField(
                                          //description 작성되었는지 확인하여 입력받은 데이터 저장
                                          onChanged: (value) {
                                            setState(() {
                                              description = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: '설명 입력',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomLeft, // 첫 번째 버튼을 왼쪽 아래로 정렬
                                          child: TextButton(
                                            style: ButtonStyle(
                                              minimumSize: MaterialStateProperty.all(Size(114, 44)), // 버튼 크기 지정
                                              backgroundColor: MaterialStateProperty.all(WHITE), // 배경색 변경
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: L_GREY,),
                                                      borderRadius: BorderRadius.circular(4)
                                                  )
                                              ), // 모서리 둥글게 처리
                                            ),
                                            child: Text('취소',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: TEXT_GREY,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            onPressed: () {
                                              // 취소 버튼을 눌렀을 때 변경사항을 초기화
                                              setState(() {
                                                title = ''; // 제목 초기화
                                                selectedRadio = 0; // 라디오 버튼 초기화
                                                selectedStartDate = DateTime.now(); // 시작 날짜 초기화
                                                selectedStartTime = DateTime.now(); // 시작 시간 초기화
                                                selectedEndDate = DateTime.now(); // 종료 날짜 초기화
                                                selectedEndTime = DateTime.now(); // 종료 시간 초기화
                                                switchValue = false; // 스위치 값 초기화
                                                description = ''; // 설명 초기화
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomRight, // 두 번째 버튼을 오른쪽 아래로 정렬
                                          child: TextButton(
                                              style: ButtonStyle(
                                                minimumSize: MaterialStateProperty.all(Size(114, 44)), // 버튼 크기 지정
                                                backgroundColor: MaterialStateProperty.all(WHITE), // 배경색 변경
                                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), // 모서리 둥글게 처리
                                              ),
                                              child: Text('저장',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: KEY_BLUE,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              onPressed: ()async{
                                                await createSchedule(context);
                                              }
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                  );
                },
              );
            },
            backgroundColor: KEY_BLUE,
            elevation: 0, // 그림자를 제거하기 위해 elevation을 0으로 설정
            shape: CircleBorder(),
            child: Icon(Icons.edit, color: WHITE),
          ),

        ),
      ],
    );
  }
  Future<void> createSchedule(BuildContext context) async {
    // 입력받은 데이터로 새로운 스케줄 데이터 생성하여 DB에 추가
    Schedule newSchedule = Schedule(
      id: user,
      title: title,
      type: selectedRadio!, // 선택된 라디오 버튼 값 사용
      start_date: selectedStartDate,
      start_time: selectedStartTime,
      end_date: selectedEndDate,
      end_time: selectedEndTime,
      isSwitched: switchValue,
      description: description,
    );

    await scheduleFirebase.addSchedule(newSchedule); // 스케줄 추가

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CalendarScreen(),
      ),
    );// 대화 상자 닫기
  }

}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
