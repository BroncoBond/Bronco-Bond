import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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
      body: Center(
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
            // Decoration for a day cell that matches the current day.
            todayTextStyle: const TextStyle(
              color: Color(0xFF3B5F43),
              fontWeight: FontWeight.bold,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF3B5F43),
                width: 1.5,
              ),
            ),
            defaultTextStyle: const TextStyle(
              color: Color(0xFFABABAB),
            ),
            weekendTextStyle: const TextStyle(
              color: Color(0xFFABABAB),
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
      ),
    );
  }

  String _getMonth() {
    return DateFormat.MMMM().format(_selectedDay);
  }

  String _getWeekRange() {
    final firstDayOfWeek =
        _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    // Format dates for week range
    final formatter = DateFormat('d');
    final firstDayFormatted = formatter.format(firstDayOfWeek);
    final lastDayFormatted = formatter.format(lastDayOfWeek);

    return '$firstDayFormatted - $lastDayFormatted';
  }
}
