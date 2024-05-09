import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

/// Displays detailed information about a SampleItem.
class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  EventsPageState createState() => EventsPageState();
}

class EventsPageState extends State<EventsPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BroncoBond',
          style: GoogleFonts.raleway(
              textStyle: Theme.of(context).textTheme.displaySmall,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3B5F43),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildWeekView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: TableCalendar(
        calendarFormat: CalendarFormat.week,
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF3B5F43),
            size: 30.0,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF3B5F43),
            size: 30.0,
          ),
        ),
        calendarStyle: CalendarStyle(
          // Decoration for day cells that are currently marked as selected by selectedDayPredicate.
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF3B5F43),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          // Decoration for a day cell that matches the current day.
          todayTextStyle: const TextStyle(
            color: Color(0xFF3B5F43),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(0xFF3B5F43),
              width: 1.5,
            ),
          ),
          weekendTextStyle: const TextStyle(
            color: Color(0xFFABABAB),
          ),
          defaultTextStyle: const TextStyle(
            color: Color(0xFFABABAB),
            fontSize: 15,
          ),
          rowDecoration: const BoxDecoration(
            color: Colors.white,
          ),
          // Decoration of single event markers. Affects each marker dot.
          // markerDecoration: BoxDecoration(
          //   color: Color.fromARGB(255, 82, 214, 111),
          //   shape: BoxShape.circle,
          // ),
          outsideDaysVisible: false,
        ),
        calendarBuilders: CalendarBuilders(dowBuilder: (context, day) {
          return Center(
            child: Text(
              DateFormat.E().format(day).substring(0, 1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFABABAB),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeekView(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    final firstDayOfWeek =
        _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    return WeekView(
      initialTime: HourMinute(hour: DateTime.now().hour).atDate(DateTime.now()),
      dates: [firstDayOfWeek, _selectedDay, lastDayOfWeek],
      style: const WeekViewStyle(
        headerSize: 0,
      ),
      dayViewStyleBuilder: (DateTime day) {
        return const DayViewStyle(
          backgroundColor: Color(0xFFECECEC),
          currentTimeRuleColor: Color(0xffFED053),
        );
      },
      hoursColumnStyle: HoursColumnStyle(
        timeFormatter: (HourMinute hourMinute) {
          final formatter = DateFormat.j();
          final time =
              TimeOfDay(hour: hourMinute.hour, minute: hourMinute.minute);
          final formattedTime = formatter.format(DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              time.hour,
              time.minute));

          return formattedTime;
        },
        textStyle: const TextStyle(
          color: Color(0xFFABABAB),
          fontSize: 14,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFECECEC),
        ),
      ),
      // Hard coded example events
      // When backend finishes, loop through array of events grabbed from the database
      // to create an event list. Then for each item, format it as a flutter week view event
      events: [
        FlutterWeekViewEvent(
          title: 'An event 1',
          description: 'A description 1',
          start: date.subtract(const Duration(hours: 0)),
          end: date.add(const Duration(hours: 3, minutes: 30)),
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Color(0xFF3B5F43),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        FlutterWeekViewEvent(
          title: 'An event 2',
          description: 'A description 2',
          start: date.add(const Duration(hours: 19)),
          end: date.add(const Duration(hours: 22)),
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: Color(0xFF3B5F43),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        FlutterWeekViewEvent(
          title: 'An event 4',
          description: 'A description 4',
          start: date.add(const Duration(hours: 20)),
          end: date.add(const Duration(hours: 21)),
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: Color(0xFF3B5F43),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        FlutterWeekViewEvent(
          title: 'An event 5',
          description: 'A description 5',
          start: date.add(const Duration(hours: 20)),
          end: date.add(const Duration(hours: 21)),
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: Color(0xFF3B5F43),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ],
    );
  }
}
