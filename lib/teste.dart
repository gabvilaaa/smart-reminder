import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';


import 'screens/settingsScreen.dart';
import 'screens/calendarScreen.dart';
import 'screens/deviceScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/searchScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminders App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePageWidget(),
    );
  }
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  int _selectedItemPosition = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SafeArea(
        child: _getBody(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SnakeNavigationBar.color(
      behaviour: SnakeBarBehaviour.floating,
      snakeShape: SnakeShape.circle,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      padding: const EdgeInsets.all(12),
      snakeViewColor: Colors.black,
      selectedItemColor: const Color.fromARGB(255, 223, 219, 219),
      unselectedItemColor: Colors.blueGrey,
      currentIndex: _selectedItemPosition,
      onTap: (index) {
        setState(() => _selectedItemPosition = index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
    );
  }

  Widget _getBody() {
    switch (_selectedItemPosition) {
      case 0:
        return const SettingsScreen();
      case 1:
        return const CalendarScreen();
      case 2:
        return const HomeScreen();
      case 3:
        return const DeviceScreen();
      case 4:
        return const SearchScreen();
      default:
        return const HomeScreen();
    }
  }
}
