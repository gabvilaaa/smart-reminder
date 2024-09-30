import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';


class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color.fromARGB(255, 223, 219, 219),
              elevation: 5,
              child: ListTile(
                title: const Text('Meeting with team'),
                subtitle: const Text('Tomorrow at 10:00 AM'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  // Navigate to event details
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(255, 223, 219, 219),
              elevation: 5,
              child: ListTile(
                title: const Text('Project Deadline'),
                subtitle: const Text('Due by end of the week'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  // Navigate to event details
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
