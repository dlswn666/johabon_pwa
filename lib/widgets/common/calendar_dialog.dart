import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:table_calendar/table_calendar.dart';

/// 커스터마이징된 달력 다이얼로그 클래스
/// table_calendar 패키지를 사용하여 날짜를 선택할 수 있는 다이얼로그를 제공합니다.
class CalendarDialog {
  /// 달력 다이얼로그를 표시하고 선택된 날짜를 반환합니다.
  /// [context]는 현재 빌드 컨텍스트입니다.
  /// [initialDate]는 초기 선택 날짜입니다(기본값: 현재 날짜에서 20년 전).
  /// [firstDate]는 선택 가능한 최초 날짜입니다(기본값: 1900년 1월 1일).
  /// [lastDate]는 선택 가능한 마지막 날짜입니다(기본값: 현재 날짜).
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime initialSelectedDate = initialDate ?? DateTime(now.year - 20, now.month, now.day);
    final DateTime firstAllowedDate = firstDate ?? DateTime(1900);
    final DateTime lastAllowedDate = lastDate ?? now;

    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return _ModernCalendarDialog(
          initialDate: initialSelectedDate,
          firstDate: firstAllowedDate,
          lastDate: lastAllowedDate,
        );
      },
    );
  }
}

/// 모던한 달력 다이얼로그 위젯
class _ModernCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _ModernCalendarDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_ModernCalendarDialog> createState() => _ModernCalendarDialogState();
}

class _ModernCalendarDialogState extends State<_ModernCalendarDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late List<int> _availableYears;
  late List<int> _availableMonths;
  
  // 현재 선택된 연도와 월
  late int _selectedYear;
  late int _selectedMonth;
  
  final DateFormat _monthFormat = DateFormat.MMMM('ko_KR'); // 월 포맷 (예: 1월, 2월, ...)
  final DateFormat _yearFormat = DateFormat.y('ko_KR'); // 연도 포맷 (예: 2023)

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
    _calendarFormat = CalendarFormat.month;
    
    // 선택 가능한 연도 범위 생성
    _availableYears = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    );
    
    // 선택 가능한 월 범위 생성 (1~12월)
    _availableMonths = List.generate(12, (index) => index + 1);
    
    // 초기 선택 연도와 월 설정
    _selectedYear = _focusedDay.year;
    _selectedMonth = _focusedDay.month;
  }
  
  // 연도 또는 월이 변경될 때 호출되는 메서드
  void _updateFocusedDay() {
    // 선택된 연도와 월로 focusedDay 업데이트
    final int lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final int day = _focusedDay.day > lastDayOfMonth ? lastDayOfMonth : _focusedDay.day;
    
    setState(() {
      _focusedDay = DateTime(_selectedYear, _selectedMonth, day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        width: isSmallScreen ? screenWidth * 0.9 : 400,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 헤더 (타이틀과 닫기 버튼)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '날짜 선택',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 연도와 월 선택 드롭다운
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 연도 선택 드롭다운
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                    elevation: 2,
                    underline: Container(height: 0), // 밑줄 제거
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontFamily: 'Wanted Sans',
                    ),
                    onChanged: (int? value) {
                      if (value != null && value != _selectedYear) {
                        setState(() {
                          _selectedYear = value;
                          _updateFocusedDay();
                        });
                      }
                    },
                    items: _availableYears.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value년'),
                      );
                    }).toList(),
                  ),
                ),
                
                // 월 선택 드롭다운
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButton<int>(
                    value: _selectedMonth,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                    elevation: 2,
                    underline: Container(height: 0), // 밑줄 제거
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontFamily: 'Wanted Sans',
                    ),
                    onChanged: (int? value) {
                      if (value != null && value != _selectedMonth) {
                        setState(() {
                          _selectedMonth = value;
                          _updateFocusedDay();
                        });
                      }
                    },
                    items: _availableMonths.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value월'),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 달력 위젯
            TableCalendar(
              locale: 'ko_KR',
              firstDay: widget.firstDate,
              lastDay: widget.lastDate,
              focusedDay: _focusedDay,
              currentDay: DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedYear = focusedDay.year;
                  _selectedMonth = focusedDay.month;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedYear = focusedDay.year;
                  _selectedMonth = focusedDay.month;
                });
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: const TextStyle(fontSize: 0), // 헤더 타이틀 숨김 (커스텀 헤더 사용)
                leftChevronVisible: false, // 왼쪽 화살표 숨김 (커스텀 드롭다운 사용)
                rightChevronVisible: false, // 오른쪽 화살표 숨김 (커스텀 드롭다운 사용)
                headerPadding: const EdgeInsets.all(0), // 헤더 패딩 제거
                headerMargin: const EdgeInsets.all(0), // 헤더 마진 제거
              ),
              calendarStyle: CalendarStyle(
                // 오늘 날짜 스타일
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                
                // 선택된 날짜 스타일
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                
                // 주말 스타일
                weekendTextStyle: const TextStyle(color: Colors.red),
                
                // 기본 날짜 셀 스타일
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                
                // 마진과 패딩 조정으로 더 깔끔한 UI
                cellMargin: const EdgeInsets.all(4),
                cellPadding: EdgeInsets.zero,
                
                // 글꼴 설정
                defaultTextStyle: const TextStyle(
                  fontFamily: 'Wanted Sans',
                  fontSize: 14,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                // 요일 헤더 커스텀 (월, 화, 수, 목, 금, 토, 일)
                dowBuilder: (context, day) {
                  final text = DateFormat.E('ko_KR').format(day);
                  Color textColor;
                  
                  if (day.weekday == DateTime.sunday) {
                    textColor = Colors.red; // 일요일 색상
                  } else if (day.weekday == DateTime.saturday) {
                    textColor = Colors.blue; // 토요일 색상
                  } else {
                    textColor = Colors.black87; // 평일 색상
                  }
                  
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Wanted Sans',
                      ),
                    ),
                  );
                },
                // 일자 셀에 커서 스타일 적용
                defaultBuilder: (context, day, focusedDay) {
                  final isSelected = isSameDay(_selectedDay, day);
                  final isToday = isSameDay(DateTime.now(), day);
                  final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                  
                  // 선택된 날짜인 경우 이미 선택된 스타일 적용됨
                  if (isSelected) return null;
                  
                  final text = day.day.toString();
                  
                  // 마우스 커서가 포인터로 변경되도록 MouseRegion 위젯 적용
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: isToday
                          ? BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isWeekend && day.weekday == DateTime.sunday
                              ? Colors.red
                              : isWeekend && day.weekday == DateTime.saturday
                                  ? Colors.blue
                                  : Colors.black87,
                          fontFamily: 'Wanted Sans',
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
                // 선택된 날짜에도 같은 방식으로 커서 스타일 적용
                selectedBuilder: (context, day, focusedDay) {
                  final text = day.day.toString();
                  
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Wanted Sans',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
                // 비활성화된 날짜 (이전/다음 달의 날짜들)에도 커서 스타일 적용
                outsideBuilder: (context, day, focusedDay) {
                  final text = day.day.toString();
                  final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                  
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isWeekend && day.weekday == DateTime.sunday
                              ? Colors.red.withOpacity(0.5)
                              : isWeekend && day.weekday == DateTime.saturday
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.5),
                          fontFamily: 'Wanted Sans',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
              rowHeight: 40, // 날짜 행 높이 설정
              daysOfWeekHeight: 32, // 요일 헤더 높이 설정
            ),
            
            const SizedBox(height: 20),
            
            // 하단 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 오늘 버튼 추가
                TextButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _selectedDay = now;
                      _focusedDay = now;
                      _selectedYear = now.year;
                      _selectedMonth = now.month;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text(
                    '오늘',
                    style: TextStyle(
                      fontFamily: 'Wanted Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                
                // 취소 버튼
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontFamily: 'Wanted Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                
                // 확인 버튼
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDay),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontFamily: 'Wanted Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 