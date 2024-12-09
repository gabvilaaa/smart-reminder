import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/database_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Map<String, dynamic>>> _events;
  List<Map<String, dynamic>> _selectedEvents = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _events = {};
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    final reminders = await DatabaseHelper().getReminders();
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (final reminder in reminders) {
      DateTime fullDate = DateTime.parse(reminder['date']);
      DateTime reminderDate = DateTime.utc(fullDate.year, fullDate.month, fullDate.day);
      if (!events.containsKey(reminderDate)) {
        events[reminderDate] = [];
      }
      events[reminderDate]!.add(reminder);
    }

    setState(() {
      _events = events;
      // _events.forEach((date, eventList) {
      //   print("Data: $date");
      //   for (var event in eventList) {
      //     print("Evento: ${event["title"]}, Descrição: ${event["description"]}");
      //   }
      // });
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000),
            lastDay: DateTime.utc(2100),
            eventLoader: _getEventsForDay,

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
              });
            },

            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(event['title']),
                    subtitle: Text(event['description']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}