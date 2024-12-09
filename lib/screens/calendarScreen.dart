import 'package:flutter/material.dart';
import 'dart:math';

import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:syncfusion_flutter_calendar/calendar.dart';

/*
class CalendarScreen extends StatefulWidget{
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "588397622893-v49pc7lmsgg49977932i4c9j80ro494u.apps.googleusercontent.com",

    // serverClientId: '588397622893-v49pc7lmsgg49977932i4c9j80ro494u.apps.googleusercontent.com',
    // signInOption: SignInOption.standard,
    scopes: <String>[GoogleAPI.CalendarApi.calendarScope],
  );

  GoogleSignInAccount? _currentUser;

  void manualSignIn() async {
    // try {
    //    _googleSignIn.hostedDomain;
    //   if (googleUser != null) {
    //     print("Usuário autenticado manualmente: ${googleUser.displayName}");
    //   } else {
    //     print("Usuário cancelou o login.");
    //   }
    // } catch (e) {
    //   print("Erro ao fazer login manual: $e");
    // }
  }


  @override
  void initState() {
    super.initState();

    print("Usuario atual ${_googleSignIn.currentUser}");
    _googleSignIn.signInSilently().whenComplete((){
      print("Login feito");
    });

    // manualSignIn();
    Future.delayed(Duration(seconds: 4)).whenComplete((){
    print("Usuario atual ${_googleSignIn.currentUser}");

    });
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      print("Login chamado");
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        getGoogleEventsData();
        print("Usuário não é nulo");
      } else {
        print("Usuário é nulo");
      }
    });

  }


  Future<List<GoogleAPI.Event>> getGoogleEventsData() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    print("login feito");
    if (googleUser == null) {
      print('Erro: Usuário não fez login.');
      return [];
    }

    print('Obtendo headers de autenticação...');
    final GoogleAPIClient httpClient = GoogleAPIClient(await googleUser!.authHeaders);

    print('Acessando API de calendário...');
    final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
    final GoogleAPI.Events calEvents = await calendarApi.events.list(
      "primary",
    );
    final List<GoogleAPI.Event> appointments = <GoogleAPI.Event>[];
    if (calEvents.items != null) {
      for (int i = 0; i < calEvents.items!.length; i++) {
        final GoogleAPI.Event event = calEvents.items![i];
        if (event.start == null) {
          continue;
        }
        appointments.add(event);
      }
    }

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder(
              future: getGoogleEventsData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Stack(
                  children: [
                    SfCalendar(
                      view: CalendarView.month,
                      initialDisplayDate: DateTime(2024, 12, 15, 9, 0, 0),
                      dataSource: GoogleDataSource(events: snapshot.data),
                      monthViewSettings: const MonthViewSettings(
                          appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment),
                    ),
                    snapshot.data != null
                        ? Container()
                        : const Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
                );
              },
            ),
            // const Text(
            //   'Upcoming Events',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 20),
            // Card(
            //   color: Color.fromRGBO(Random().nextInt(255),
            //         Random().nextInt(255),
            //         Random().nextInt(255),
            //         Random().nextDouble()),
            //   elevation: 5,
            //   child: ListTile(
            //     title: const Text('Meeting with team'),
            //     subtitle: const Text('Tomorrow at 10:00 AM'),
            //     trailing: const Icon(Icons.calendar_today),
            //     onTap: () {
            //       // Navigate to event details
            //     },
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Card(
            //   color: Color.fromRGBO(Random().nextInt(255),
            //         Random().nextInt(255),
            //         Random().nextInt(255),
            //         Random().nextDouble()),
            //   elevation: 5,
            //   child: ListTile(
            //     title: const Text('Project Deadline'),
            //     subtitle: const Text('Due by end of the week'),
            //     trailing: const Icon(Icons.calendar_today),
            //     onTap: () {
            //       // Navigate to event details
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<GoogleAPI.Event>? events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.start?.date ?? event.start!.dateTime!.toLocal();
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.endTimeUnspecified != null && event.endTimeUnspecified!
        ? (event.start?.date ?? event.start!.dateTime!.toLocal())
        : (event.end?.date != null
        ? event.end!.date!.add(const Duration(days: -1))
        : event.end!.dateTime!.toLocal());
  }

  @override
  String getLocation(int index) {
    return appointments![index].location ?? '';
  }

  @override
  String getNotes(int index) {
    return appointments![index].description ?? '';
  }

  @override
  String getSubject(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.summary == null || event.summary!.isEmpty
        ? 'No Title'
        : event.summary!;
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
}
*/
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/database_helper.dart'; // Importando o helper para buscar lembretes

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Map<String, dynamic>>> _events = {}; // Eventos por data
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Carregar eventos ao iniciar
  }

  Future<void> _loadEvents() async {
    List<Map<String, dynamic>> reminders = await DatabaseHelper().getReminders();
    Map<DateTime, List<Map<String, dynamic>>> events = {};
    for (var reminder in reminders) {
      DateTime fullDate = DateTime.parse(reminder['date']);
      DateTime reminderDate = DateTime(fullDate.year, fullDate.month, fullDate.day);
      if (events[reminderDate] == null) {
        events[reminderDate] = [];
      }
      events[reminderDate]!.add(reminder);
    }
    setState(() {
      _events = events;
    });
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
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2000, 01, 01),
            lastDay: DateTime.utc(2101, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events[_selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                var reminder = _events[_selectedDay]?[index];
                return Card(
                  child: ListTile(
                    title: Text(reminder?['title'] ?? 'No Title'),
                    subtitle: Text(reminder?['description'] ?? 'No Description'),
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

