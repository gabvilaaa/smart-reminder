import 'package:flutter/material.dart';
import 'dart:math';

import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';

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
              color: Color.fromRGBO(Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextDouble()),
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
              color: Color.fromRGBO(Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextDouble()),
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
