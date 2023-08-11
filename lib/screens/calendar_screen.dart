/*
캘린더 화면
bottomTabBar : o
 */

import 'package:board_project/widgets/listtile_sheet.dart';
import 'package:flutter/cupertino.dart';
import '../../../constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:board_project/providers/schedule_firestore.dart';
import 'package:board_project/models/schedule.dart';
import 'dart:async';
import '../constants/list.dart';
import '../constants/size.dart';
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
  bool switchValue = false;
  int? selectedRadio = COMMON_INIT_COUNT;

  //스케줄 이름, 상세 내용 초기화
  String title = '';
  String description = '';

  // 현재 로그인한 사용자 name
  late String user;

  List<Meeting> meetings = <Meeting>[];

  @override
  void initState() {
    super.initState();
    initializeData();
    setState(() {
      // firebase 객체 초기화
      scheduleFirebase.initDb();
      userFirebase.initDb();// Initialize the database
    });
    // user_id 값을 가져와서 user 변수에 할당
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
        schedule.type == 0 ? const Color(0xFFAFD67D) : schedule.type == 2 ? const Color(0xFFD7A6FE) : const Color(0xFFFFB444),
        schedule.isSwitched,
      );
    }).toList();

    // 화면을 다시 그리도록 갱신
    setState(() {});
  }

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
  Widget build(BuildContext context) {
    final double statusBarSize = MediaQuery.of(context).padding.top;

    return Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: statusBarSize, bottom: BOTTOM_TAB),
          child: SfCalendar(
            // 캘린더 보이는 방식
            view: CalendarView.month,
            dataSource: MeetingDataSource(meetings),
            monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              // 현재 달 제외하고 날짜 표시 x
              showTrailingAndLeadingDates: false,
            ),
            // 캘린더 오늘 날짜 border 색
            todayHighlightColor: D_GREY,
            // 캘린더 오늘 날짜 스타일
            todayTextStyle: TextStyle(
              color: WHITE,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            // 캘린더 구분선 색
            cellBorderColor: L_GREY,

            // 캘린더 헤더 날짜 표시
            headerDateFormat: 'yyyy년 MM월',
            // 캘린더 헤더 날짜 스타일
            headerStyle: CalendarHeaderStyle(
                textStyle: TextStyle(
                  color: BLACK,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center
            ),

            // 캘린더 뷰 요일 스타일
            viewHeaderStyle: ViewHeaderStyle(
              backgroundColor: WHITE,
              dateTextStyle: TextStyle(
                color: D_GREY,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),

            // 캘린더 이전/다음 달 버튼 표시
            showNavigationArrow: true,

            // 날짜를 눌렀을 때 다이얼로그 표시
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.calendarCell) {
                DateTime tappedDate = details.date!;

                List<Meeting> appointmentsForDate = meetings.where((meeting) {
                  return (meeting.from.isBefore(tappedDate) && meeting.to.isAfter(tappedDate) ||
                      (meeting.from.year == tappedDate.year && meeting.from.month == tappedDate.month && meeting.from.day == tappedDate.day));
                }).toList();

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ROUND_BORDER)),
                        backgroundColor: Colors.transparent,
                        child: Container(
                            width: 320,
                            height: 374,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: WHITE,
                              borderRadius: BorderRadius.circular(ROUND_BORDER),
                            ),
                            child: Column(
                              children: [
                                Text('${DateFormat('yyyy.  M. dd. E', 'ko_KR').format(tappedDate)}',
                                  style: TextStyle(
                                    color: tappedDate.weekday == DateTime.saturday || tappedDate.weekday == DateTime.sunday ? ALERT_RED : BLACK,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                appointmentsForDate.isNotEmpty
                                  ? Column(
                                  children: appointmentsForDate.map((appointment) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          visualDensity: VisualDensity.compact,
                                          contentPadding: EdgeInsets.zero,
                                          leading: Container(
                                            width: 24,
                                            height: 16,
                                            decoration: ShapeDecoration(
                                              color: appointment.background,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                                            ),
                                          ),
                                          title: Text(appointment.eventName,
                                            style: TextStyle(
                                              color: BLACK,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.more_vert),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                  backgroundColor: WHITE,
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        ListtileSheet(name: '자세히 보기', color: BLACK, onTab: () {}),
                                                        ListtileSheet(name: '삭제', color: ALERT_RED, onTab: () {}),
                                                      ],
                                                    );
                                                  });
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 37),
                                          child: Text('${appointment.from} ~ ${appointment.to}',
                                            style: TextStyle(
                                              color: D_GREY,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                )
                                    : Text('일정이 없습니다.'),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit_calendar_outlined, color: KEY_BLUE,),
                                      SizedBox(width: 5,),
                                      Text('스케줄 추가',
                                        style: TextStyle(
                                          color: KEY_BLUE,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ))
                      );
                    }
                );
              }
            },
          ),
        ),
        //일정 추가 버튼 생성
        floatingActionButton: buildFloating(context)
    );
  }

  // 일정 추가 버튼 UI
  Stack buildFloating(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: BOTTOM_TAB, // 아래쪽 여백
          right: 0, // 오른쪽 여백
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                title = ''; // 제목 초기화
                selectedRadio = COMMON_INIT_COUNT; // 라디오 버튼 초기화
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
                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ROUND_BORDER)),
                    backgroundColor: Colors.transparent,
                    child: SingleChildScrollView(
                      child: StatefulBuilder(
                        builder: (__, StateSetter setDialogState) {
                          return Container(
                            width: 320,
                            height: 457.41,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: WHITE,
                              borderRadius: BorderRadius.circular(ROUND_BORDER),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 제목
                                Text('스케줄 추가',
                                  style: TextStyle(
                                    color: BLACK,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // radio 버튼
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List<Widget>.generate(3, (int index) {
                                    return Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: <Widget>[
                                          Transform.scale(
                                            scale: 0.75,
                                            child: Radio(
                                              value: index,
                                              groupValue: selectedRadio,
                                              activeColor: selectedRadio == index ? ScheduleColorList[index] : TEXT_GREY,
                                              onChanged: (int? value) {
                                                setState(() {
                                                  if (value != selectedRadio) { // 값이 변경되었을 때만 setState 호출
                                                    setDialogState(() => selectedRadio = value);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          Text(ScheduleTypeList[index],
                                            style: TextStyle(
                                              color: selectedRadio == index ? ScheduleColorList[index] : TEXT_GREY,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                // 일정 제목
                                Container(
                                  width: 288,
                                  height: 30,
                                  decoration: ShapeDecoration(
                                    color: L_GREY,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 0.50, color: L_GREY),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: TextField(
                                    onChanged: (value){
                                      setState(() {
                                        title = value;
                                      });
                                    },
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      hintText: '스케줄 이름을 입력해주세요.',
                                      hintStyle: TextStyle(
                                        color: TEXT_GREY,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                                    ),
                                  ),
                                ),
                                // 날짜 및 시간 설정
                                Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Container(
                                    width: 320,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.50,
                                          strokeAlign: BorderSide.strokeAlignCenter,
                                          color: L_GREY,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Icon(Icons.query_builder, color: D_GREY, size: 25,),
                                        SizedBox(height: 45,)
                                      ],
                                    ),
                                    // 일정 시작 날짜 및 종료 날짜
                                    Column(
                                      children: [
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
                                                          },
                                                          mode: CupertinoDatePickerMode.date,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: CupertinoDatePicker(
                                                          initialDateTime: selectedEndDate,
                                                          onDateTimeChanged: (DateTime newDate) {
                                                            setDialogState(() => selectedEndDate = newDate);
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
                                          padding: EdgeInsets.only(left: 16),
                                          child: Row(
                                            children: [
                                              Text(
                                                // 일정 시작 날짜 텍스트
                                                '${DateFormat('yyyy.MM.dd').format(selectedStartDate)}',
                                                style: TextStyle(
                                                  color: BLACK,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(width: 40,),
                                              Text(
                                                // 일정 종료 날짜 텍스트
                                                '${DateFormat('yyyy.MM.dd').format(selectedEndDate)}',
                                                style: TextStyle(
                                                  color: BLACK,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 일정 시작 및 종료 시간
                                        CupertinoButton(
                                          onPressed: switchValue ? null : () {
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
                                                          },
                                                          mode: CupertinoDatePickerMode.time,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: CupertinoDatePicker(
                                                          initialDateTime: selectedEndTime,
                                                          onDateTimeChanged: (DateTime newDate) {
                                                            setDialogState(() => selectedEndTime = newDate);
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
                                          padding: EdgeInsets.only(left: 16),
                                          child: Row(
                                            children: [
                                              // 시작 시간 텍스트
                                              Text(
                                                '${DateFormat('HH.mm').format(selectedStartTime)}',
                                                style: TextStyle(
                                                  color: switchValue ? D_GREY : BLACK,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(width: 70,),
                                              // 종료 시간 텍스트
                                              Text(
                                                '${DateFormat('HH.mm').format(selectedEndTime)}',
                                                style: TextStyle(
                                                  color: switchValue ? D_GREY : BLACK,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 320,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 0.50,
                                        strokeAlign: BorderSide.strokeAlignCenter,
                                        color: L_GREY,
                                      ),
                                    ),
                                  ),
                                ),
                                // 종일 스위치 버튼
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('종일',
                                      style: TextStyle(
                                      color: switchValue ? BLACK : TEXT_GREY,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),),
                                    Transform.scale(
                                      scale: 0.7, // 원하는 크기 비율 조정
                                      child: CupertinoSwitch(
                                        value: switchValue,
                                        activeColor: KEY_BLUE,
                                        onChanged: (bool value) {
                                          setDialogState(() => switchValue = value);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                //스케줄 상세 내용
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Icon(Icons.sticky_note_2_outlined, color: ICON_GREY,),
                                        ),
                                        SizedBox(height: 40,)
                                      ],
                                    ),
                                    SizedBox(
                                      width: 190,
                                      child: TextField(
                                        //description 작성되었는지 확인하여 입력받은 데이터 저장
                                        onChanged: (value) {
                                          setState(() {
                                            description = value;
                                          });
                                        },
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: '설명 입력',
                                          hintStyle: TextStyle(
                                            color: TEXT_GREY,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                // 저장 & 취소 버튼
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomLeft, // 첫 번째 버튼을 왼쪽 아래로 정렬
                                        child: TextButton(
                                          style: ButtonStyle(
                                            minimumSize: MaterialStateProperty.all(Size(80, 30)), // 버튼 크기 지정
                                            backgroundColor: MaterialStateProperty.all(WHITE), // 배경색 변경
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
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
                                              selectedRadio = COMMON_INIT_COUNT; // 라디오 버튼 초기화
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
                                              minimumSize: MaterialStateProperty.all(Size(80, 30)), // 버튼 크기 지정
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
            child: Icon(Icons.edit_calendar_outlined, color: WHITE),
          ),

        ),
      ],
    );
  }

  // DB에 입력받은 스케줄 데이터 생성하여 추가
  Future<void> createSchedule(BuildContext context) async {
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
    );
  }
}

/// 나중에 코드 분리
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
