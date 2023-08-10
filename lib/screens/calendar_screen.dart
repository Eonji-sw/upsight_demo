/*
캘린더 화면
 */

import 'package:flutter/cupertino.dart';
import '../../../constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:board_project/providers/schedule_firestore.dart';
import 'package:board_project/models/schedule.dart';
import '../providers/user_firestore.dart';


class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  ScheduleFirebase scheduleFirebase = ScheduleFirebase();
  UserFirebase userFirebase = UserFirebase();

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  DateTime selectedEndTime = DateTime.now();

  String text = '';
  List lst = ['청약', '목표', '일정'];
  bool switchValue = false;
  int? selectedRadio = 0;

  List colorList = [CALENDAR_GREEN, CALENDAR_YELLOW, CALENDAR_PURPLE];

  //스케줄 이름, 상세 내용 초기화
  String title = '';
  String description = '';

  // 현재 로그인한 사용자 name
  late String user;

  // Stream to get the 스케줄 data
  late Stream<List<Schedule>> scheduleStream;

  @override
  void initState() {
    super.initState();
    setState(() {
      // firebase 객체 초기화
      scheduleFirebase.initDb();
      userFirebase.initDb();// Initialize the database
      scheduleStream = scheduleFirebase.getSchedules(); // Get the schedule data through the stream
    });
    // user_id 값을 가져와서 user 변수에 할당
    fetchUser();
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
    return Scaffold(
        body: SfCalendar(
          // 캘린더 보이는 방식
          view: CalendarView.month,
          // 캘린더 오늘 날짜 border 색
          todayHighlightColor: Color(0xFF585858),
          // 캘린더 오늘 날짜 스타일
          todayTextStyle: TextStyle(
            color: WHITE,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          // 캘린더 구분선 색
          cellBorderColor: Color(0xFFE5EAEF),

          // 캘린더 헤더 날짜 표시
          headerDateFormat: 'yyy MM',
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
            backgroundColor: Color(0xFFE5EAEF),
          ),

          // 캘린더 이전/다음 달 버튼 표시
          showNavigationArrow: true,
        ),
        //일정 추가 버튼 생성
        floatingActionButton: buildFloating(context));
  }
  // 일정 추가 버튼 UI
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
                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              borderRadius: BorderRadius.circular(16),
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
                                          Radio(
                                            value: index,
                                            groupValue: selectedRadio,
                                            activeColor: selectedRadio == index ? colorList[index] : TEXT_GREY,
                                            onChanged: (int? value) {
                                              setState(() {
                                                if (value != selectedRadio) { // 값이 변경되었을 때만 setState 호출
                                                  setDialogState(() => selectedRadio = value);
                                                }
                                              });
                                            },
                                          ),
                                          Text(lst[index],
                                            style: TextStyle(
                                              color: selectedRadio == index ? colorList[index] : TEXT_GREY,
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
                                                  color: BLACK,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(width: 70,),
                                              // 종료 시간 텍스트
                                              Text(
                                                '${DateFormat('HH.mm').format(selectedEndTime)}',
                                                style: TextStyle(
                                                  color: BLACK,
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
                                      color: TEXT_GREY,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),),
                                    Transform.scale(
                                      scale: 0.7, // 원하는 크기 비율 조정
                                      child: CupertinoSwitch(
                                        value: switchValue,
                                        activeColor: CupertinoColors.activeBlue,
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

    Navigator.pop(context); // 대화 상자 닫기
  }
}



